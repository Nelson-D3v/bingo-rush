## Carrega e fornece acesso ao game_config.json.
## Suporta recarregamento em runtime para painel admin.
extends Node

const CONFIG_PATH := "res://config/game_config.json"

var config: Dictionary = {}

func _ready() -> void:
	load_config()

func load_config(path: String = CONFIG_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ConfigLoader: não foi possível abrir: " + path)
		_apply_defaults()
		return false

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("ConfigLoader: erro JSON na linha %d: %s" % [json.get_error_line(), json.get_error_message()])
		_apply_defaults()
		return false

	config = json.get_data()
	print("ConfigLoader: config carregado (v%s)" % get_value("version", "?"))
	return true

## Acessa valores com dot-path. Ex: get_value("economy.card_cost", 1)
func get_value(path: String, default_value = null) -> Variant:
	var keys := path.split(".")
	var node: Variant = config
	for key in keys:
		if typeof(node) != TYPE_DICTIONARY or not node.has(key):
			return default_value
		node = node[key]
	return node

func _apply_defaults() -> void:
	config = {
		"version": "0.0.0-fallback",
		"economy": {"card_cost": 1, "max_cards": 4, "starting_coins": 100, "rtp_target": 0.68},
		"draw": {"total_numbers": 60, "numbers_per_round": 30, "draw_interval_seconds": 0.8, "turbo_interval_seconds": 0.25},
		"extra_balls": {
			"base_cost": 2,
			"cost_multiplier_1_away": 8,
			"cost_multiplier_2_away": 4,
			"cost_multiplier_3_away": 2,
			"max_extra_balls": 5
		},
		"events": {"bonus_ball_chance": 0.05, "multiplier_chance": 0.04, "turbo_round_chance": 0.08, "multiplier_values": [1.5, 2.0, 3.0]},
		"progression": {"xp_per_round": 10, "xp_per_win": 50, "xp_per_level": 200},
		"patterns": []
	}
