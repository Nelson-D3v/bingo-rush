## Verifica padrões de vitória em grade 3×5 (15 células, índices 0-14).
## Layout:
##   [00][01][02][03][04]
##   [05][06][07][08][09]
##   [10][11][12][13][14]
class_name PatternChecker
extends Node

var _patterns: Array = []

func _ready() -> void:
	_load_patterns()

func _load_patterns() -> void:
	var raw: Array = ConfigLoader.get_value("patterns", [])
	_patterns = raw if not raw.is_empty() else _builtin_patterns()

## Retorna lista de vitórias {card_id, pattern_id, pattern_name, reward_multiplier, winning_cells}
func check_cards(cards: Array) -> Array[Dictionary]:
	var wins: Array[Dictionary] = []
	for card in cards:
		if card["won"]:
			continue
		var w := _check_card(card)
		if not w.is_empty():
			wins.append(w)
	return wins

func _check_card(card: Dictionary) -> Dictionary:
	var marked := {}
	for idx in card["marked"]:
		marked[idx] = true

	var sorted := _patterns.duplicate(true)
	sorted.sort_custom(func(a, b): return int(a["difficulty"]) < int(b["difficulty"]))

	for pat in sorted:
		for group in pat["cells"]:
			if _all_marked(group, marked):
				return {
					"card_id": card["id"],
					"pattern_id": pat["id"],
					"pattern_name": pat["name"],
					"reward_multiplier": int(pat["reward_multiplier"]),
					"winning_cells": group
				}
	return {}

## Retorna near-wins com 1-3 números faltando, ordenados por proximidade.
func get_near_wins(cards: Array) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for card in cards:
		if card["won"]:
			continue
		var marked := {}
		for idx in card["marked"]:
			marked[idx] = true

		for pat in _patterns:
			if pat["id"] == "full_card":
				continue
			for group in pat["cells"]:
				var missing: Array[int] = []
				for idx in group:
					if not marked.has(idx):
						missing.append(idx)
				if missing.size() in [1, 2, 3]:
					results.append({
						"card_id": card["id"],
						"pattern_id": pat["id"],
						"pattern_name": pat["name"],
						"numbers_away": missing.size(),
						"missing_cells": missing,
						"reward_multiplier": int(pat["reward_multiplier"])
					})

	results.sort_custom(func(a, b): return a["numbers_away"] < b["numbers_away"])
	return results

func _all_marked(group: Array, marked: Dictionary) -> bool:
	for idx in group:
		if not marked.has(idx):
			return false
	return true

func _builtin_patterns() -> Array:
	return [
		{"id": "column",    "name": "Coluna",       "difficulty": 1,  "reward_multiplier": 2,
		 "cells": [[0,5,10],[1,6,11],[2,7,12],[3,8,13],[4,9,14]]},
		{"id": "line",      "name": "Linha",         "difficulty": 2,  "reward_multiplier": 4,
		 "cells": [[0,1,2,3,4],[5,6,7,8,9],[10,11,12,13,14]]},
		{"id": "two_lines", "name": "Duas Linhas",   "difficulty": 5,  "reward_multiplier": 12,
		 "cells": [[0,1,2,3,4,5,6,7,8,9],[0,1,2,3,4,10,11,12,13,14],[5,6,7,8,9,10,11,12,13,14]]},
		{"id": "full_card", "name": "Cartela Cheia", "difficulty": 10, "reward_multiplier": 40,
		 "cells": [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]]}
	]
