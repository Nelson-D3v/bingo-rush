## Máquina de estados principal.
##
## Fluxo:
##   IDLE
##   → prepare_cards(n)   → CARD_SELECTION  (gratuito, pode trocar cartelas)
##   → confirm_and_start() → DRAWING         (cobra moedas aqui)
##   → CHECKING_WIN
##   → EXTRA_BALL_OFFER   (se near-win)
##   → REWARDING
##   → IDLE
class_name GameManager
extends Node

enum State {
	IDLE,
	CARD_SELECTION,
	DRAWING,
	CHECKING_WIN,
	EXTRA_BALL_OFFER,
	REWARDING
}

var draw_manager: DrawManager
var card_manager: CardManager
var pattern_checker: PatternChecker
var reward_manager: RewardManager
var extra_ball_system: ExtraBallSystem

var state: State = State.IDLE
var cards_count: int = 1
var current_wins: Array[Dictionary] = []
var current_near_wins: Array[Dictionary] = []
var active_multiplier: float = 1.0

func _ready() -> void:
	draw_manager    = DrawManager.new()
	card_manager    = CardManager.new()
	pattern_checker = PatternChecker.new()
	reward_manager  = RewardManager.new()
	extra_ball_system = ExtraBallSystem.new()

	add_child(draw_manager)
	add_child(card_manager)
	add_child(pattern_checker)
	add_child(reward_manager)
	add_child(extra_ball_system)

	draw_manager.draw_completed.connect(_on_draw_completed)
	GameEvents.number_drawn.connect(_on_number_drawn)

# ── API pública ───────────────────────────────────────────────────────────────

## Fase 1: Gera cartelas gratuitamente e entra em modo de seleção.
## O jogador pode visualizar e trocar antes de confirmar.
func prepare_cards(count: int) -> void:
	# Permite trocar quantidade mesmo dentro de CARD_SELECTION (pré-jogo)
	if state != State.IDLE and state != State.CARD_SELECTION:
		return
	cards_count = count
	current_wins.clear()
	current_near_wins.clear()
	card_manager.generate_cards(count)
	_set_state(State.CARD_SELECTION)
	GameEvents.cards_prepared.emit(count)

## Troca uma cartela pelo ID — só permitido em CARD_SELECTION.
func swap_card(card_id: int) -> Dictionary:
	if state != State.CARD_SELECTION:
		return {}
	return card_manager.swap_card(card_id)

## Fase 2: Cobra as moedas e inicia o sorteio.
func confirm_and_start() -> bool:
	if state != State.CARD_SELECTION:
		return false

	var cost: int = cards_count * int(ConfigLoader.get_value("economy.card_cost", 1))
	if not SaveManager.spend_coins(cost):
		return false

	extra_ball_system.reset()
	active_multiplier = reward_manager.roll_event_multiplier()

	if reward_manager.roll_turbo_round():
		draw_manager.set_turbo(true)
	else:
		draw_manager.set_turbo(false)

	SaveManager.player_data["rounds_played"] += 1
	SaveManager.add_xp(ConfigLoader.get_value("progression.xp_per_round", 10))
	GameEvents.cards_purchased.emit(cards_count, cost)

	_set_state(State.DRAWING)
	draw_manager.start_round()
	GameEvents.round_started.emit()
	return true

## Compra bola extra (só em EXTRA_BALL_OFFER).
func purchase_extra_ball() -> bool:
	if state != State.EXTRA_BALL_OFFER:
		return false
	var cost := extra_ball_system.calculate_cost(current_near_wins, cards_count)
	if not extra_ball_system.purchase(cost):
		return false

	_set_state(State.DRAWING)
	var number := draw_manager.draw_extra_ball()
	if number == -1:
		_end_no_win()
		return true

	card_manager.mark_number(number)
	_evaluate()
	return true

func decline_extra_ball() -> void:
	GameEvents.extra_ball_declined.emit()
	_end_no_win()

func is_idle() -> bool:
	return state == State.IDLE

func is_selecting() -> bool:
	return state == State.CARD_SELECTION

func get_state_name() -> String:
	return State.keys()[state]

# ── Internos ──────────────────────────────────────────────────────────────────

func _on_number_drawn(number: int) -> void:
	card_manager.mark_number(number)

func _on_draw_completed(_drawn: Array) -> void:
	_evaluate()

func _evaluate() -> void:
	_set_state(State.CHECKING_WIN)
	current_wins = pattern_checker.check_cards(card_manager.get_cards())

	if not current_wins.is_empty():
		_process_wins()
		return

	current_near_wins = pattern_checker.get_near_wins(card_manager.get_cards())

	# Bola bônus gratuita (evento raro)
	if reward_manager.roll_bonus_ball() and draw_manager.get_remaining_count() > 0:
		var n := draw_manager.draw_extra_ball()
		if n != -1:
			card_manager.mark_number(n)
			current_wins = pattern_checker.check_cards(card_manager.get_cards())
			if not current_wins.is_empty():
				_process_wins()
				return
			current_near_wins = pattern_checker.get_near_wins(card_manager.get_cards())

	_offer_extra_ball()

func _offer_extra_ball() -> void:
	if current_near_wins.is_empty() or not extra_ball_system.can_offer():
		_end_no_win()
		return
	var cost := extra_ball_system.calculate_cost(current_near_wins, cards_count)
	if cost <= 0 or cost > SaveManager.get_coins():
		_end_no_win()
		return

	SaveManager.player_data["stats"]["near_wins"] += 1
	var best := current_near_wins[0]
	GameEvents.near_win_detected.emit(best["card_id"], best["pattern_id"], best["numbers_away"])
	_set_state(State.EXTRA_BALL_OFFER)
	GameEvents.extra_ball_offered.emit(cost, best["numbers_away"])

func _process_wins() -> void:
	_set_state(State.REWARDING)
	var total := 0
	for win in current_wins:
		card_manager.mark_card_won(win["card_id"], win["pattern_id"])
		var reward := reward_manager.calculate_reward(win["pattern_id"], cards_count, active_multiplier)
		total += reward
		GameEvents.pattern_completed.emit(win["card_id"], win["pattern_id"], reward)

	reward_manager.grant_reward(total, "bingo")
	SaveManager.player_data["rounds_won"] += 1
	var streak: int = SaveManager.player_data["stats"]["current_streak"] + 1
	SaveManager.player_data["stats"]["current_streak"] = streak
	if streak > SaveManager.player_data["stats"]["best_streak"]:
		SaveManager.player_data["stats"]["best_streak"] = streak

	GameEvents.round_ended.emit(true)
	_set_state(State.IDLE)

func _end_no_win() -> void:
	SaveManager.player_data["stats"]["current_streak"] = 0
	SaveManager.save_game()
	GameEvents.round_ended.emit(false)
	_set_state(State.IDLE)

func _set_state(new_state: State) -> void:
	state = new_state
	GameEvents.game_state_changed.emit(State.keys()[new_state])
