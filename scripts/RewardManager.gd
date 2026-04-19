## Calcula e concede prêmios. Controla eventos especiais (multiplicador, turbo).
class_name RewardManager
extends Node

## Calcula prêmio bruto antes de aplicar multiplicador.
func calculate_reward(pattern_id: String, cards_purchased: int, multiplier: float = 1.0) -> int:
	var card_cost: int = ConfigLoader.get_value("economy.card_cost", 1)
	var invested := cards_purchased * card_cost
	var pat_mult := _pattern_multiplier(pattern_id)
	return int(invested * pat_mult * multiplier)

func grant_reward(amount: int, reason: String) -> void:
	SaveManager.add_coins(amount)
	SaveManager.add_xp(ConfigLoader.get_value("progression.xp_per_win", 50))
	GameEvents.reward_granted.emit(amount, reason)

## Retorna multiplicador de evento (1.0 = sem evento).
func roll_event_multiplier() -> float:
	var chance: float = ConfigLoader.get_value("events.multiplier_chance", 0.04)
	if randf() >= chance:
		return 1.0
	var values: Array = ConfigLoader.get_value("events.multiplier_values", [1.5, 2.0, 3.0])
	if values.is_empty():
		return 1.0
	var mult: float = float(values[randi() % values.size()])
	GameEvents.multiplier_activated.emit(mult)
	GameEvents.special_event_triggered.emit("multiplier")
	return mult

func roll_turbo_round() -> bool:
	var chance: float = ConfigLoader.get_value("events.turbo_round_chance", 0.08)
	var triggered := randf() < chance
	if triggered:
		GameEvents.special_event_triggered.emit("turbo")
	return triggered

func roll_bonus_ball() -> bool:
	var chance: float = ConfigLoader.get_value("events.bonus_ball_chance", 0.05)
	var triggered := randf() < chance
	if triggered:
		GameEvents.bonus_ball_triggered.emit()
		GameEvents.special_event_triggered.emit("bonus_ball")
	return triggered

func _pattern_multiplier(pattern_id: String) -> int:
	var patterns: Array = ConfigLoader.get_value("patterns", [])
	for p in patterns:
		if p["id"] == pattern_id:
			return int(p["reward_multiplier"])
	return 2
