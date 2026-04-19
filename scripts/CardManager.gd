## Gerencia geração e troca de cartelas com pool único garantido.
## Regra: nenhum número se repete dentro ou entre cartelas do mesmo jogador.
class_name CardManager
extends Node

var _cards: Array[Dictionary] = []
var _total_numbers: int = 60
var _numbers_per_card: int = 15

func _ready() -> void:
	_total_numbers   = ConfigLoader.get_value("draw.total_numbers", 60)
	_numbers_per_card = ConfigLoader.get_value("card.numbers_per_card", 15)

# ── Geração ───────────────────────────────────────────────────────────────────

## Gera `count` cartelas com números únicos entre todas.
## Máx: 4 cartelas × 15 = 60 → usa todos os números disponíveis.
func generate_cards(count: int) -> Array[Dictionary]:
	_cards.clear()

	# Pool global embaralhado, fatia em blocos de 15
	var pool: Array[int] = []
	for i in range(1, _total_numbers + 1):
		pool.append(i)
	pool.shuffle()

	for id in range(count):
		var start := id * _numbers_per_card
		var nums := pool.slice(start, start + _numbers_per_card)
		_cards.append(_make_card(id, nums))

	return _cards.duplicate(true)

## Troca a cartela `card_id` por uma nova gerada com os números disponíveis.
## Números das outras cartelas são preservados intactos.
func swap_card(card_id: int) -> Dictionary:
	var idx := _find_index(card_id)
	if idx == -1:
		return {}

	# Constrói conjunto de números já usados pelas OUTRAS cartelas
	var used := {}
	for i in range(_cards.size()):
		if i == idx:
			continue
		for n in _cards[i]["numbers"]:
			used[n] = true

	# Pool disponível: tudo que não está nas outras cartelas
	var available: Array[int] = []
	for n in range(1, _total_numbers + 1):
		if not used.has(n):
			available.append(n)

	if available.size() < _numbers_per_card:
		push_warning("CardManager: pool insuficiente para trocar cartela %d" % card_id)
		return {}

	available.shuffle()
	var new_nums := available.slice(0, _numbers_per_card)
	var new_card := _make_card(card_id, new_nums)
	_cards[idx] = new_card

	GameEvents.card_swapped.emit(card_id)
	return new_card.duplicate(true)

# ── Marcação ──────────────────────────────────────────────────────────────────

func mark_number(number: int) -> void:
	for card in _cards:
		for i in range(card["numbers"].size()):
			if card["numbers"][i] == number and not (i in card["marked"]):
				card["marked"].append(i)
				GameEvents.card_number_marked.emit(card["id"], number, i)

func mark_card_won(card_id: int, pattern_id: String) -> void:
	var idx := _find_index(card_id)
	if idx != -1:
		_cards[idx]["won"] = true
		_cards[idx]["win_pattern"] = pattern_id

# ── Consulta ──────────────────────────────────────────────────────────────────

func get_cards() -> Array[Dictionary]:
	return _cards.duplicate(true)

func get_card(card_id: int) -> Dictionary:
	var idx := _find_index(card_id)
	return _cards[idx].duplicate(true) if idx != -1 else {}

func reset() -> void:
	_cards.clear()

# ── Internos ──────────────────────────────────────────────────────────────────

func _make_card(id: int, numbers: Array) -> Dictionary:
	return {
		"id": id,
		"numbers": numbers,
		"marked": [],
		"won": false,
		"win_pattern": ""
	}

func _find_index(card_id: int) -> int:
	for i in range(_cards.size()):
		if _cards[i]["id"] == card_id:
			return i
	return -1
