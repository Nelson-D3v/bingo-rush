## Sistema de bolas extras: precificação dinâmica baseada em proximidade e prêmio potencial.
## Custo é calculado para ser tentador, mas raramente racional no longo prazo.
class_name ExtraBallSystem
extends Node

var _bought_this_round: int = 0
var _max_per_round: int = 5

func reset() -> void:
	_bought_this_round = 0
	_max_per_round = ConfigLoader.get_value("extra_balls.max_extra_balls", 5)

func can_offer() -> bool:
	return _bought_this_round < _max_per_round

## Calcula custo baseado na melhor near-win disponível.
## Retorna -1 se não deve oferecer (muito longe ou sem near-wins).
func calculate_cost(near_wins: Array, cards_purchased: int) -> int:
	if near_wins.is_empty() or not can_offer():
		return -1

	var best: Dictionary = near_wins[0]
	var away: int = best["numbers_away"]
	if away > 3:
		return -1

	var card_cost: int = ConfigLoader.get_value("economy.card_cost", 1)
	var potential: int = cards_purchased * card_cost * int(best["reward_multiplier"])
	var base_cost: int = ConfigLoader.get_value("extra_balls.base_cost", 2)

	var fraction: float
	match away:
		1: fraction = ConfigLoader.get_value("extra_balls.cost_multiplier_1_away", 8) / 10.0
		2: fraction = ConfigLoader.get_value("extra_balls.cost_multiplier_2_away", 4) / 10.0
		3: fraction = ConfigLoader.get_value("extra_balls.cost_multiplier_3_away", 2) / 10.0
		_: return -1

	# Custo = fração do prêmio potencial — tentador mas esperança negativa
	var cost := int(potential * fraction)
	return maxi(cost, base_cost)

func purchase(cost: int) -> bool:
	if not can_offer():
		return false
	if not SaveManager.spend_coins(cost):
		return false
	_bought_this_round += 1
	SaveManager.player_data["stats"]["extra_balls_bought"] += 1
	GameEvents.extra_ball_purchased.emit(cost)
	return true

func get_bought_count() -> int:
	return _bought_this_round
