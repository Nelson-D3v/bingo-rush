## Gerencia persistência do jogador. Moedas, XP, conquistas e estatísticas.
extends Node

const SAVE_PATH := "user://bingo_rush_save.json"

var player_data: Dictionary = {}

func _ready() -> void:
	_init_defaults()
	load_game()

func _init_defaults() -> void:
	var starting_coins: int = ConfigLoader.get_value("economy.starting_coins", 100)
	player_data = {
		"coins": starting_coins,
		"total_spent": 0,
		"total_won": 0,
		"rounds_played": 0,
		"rounds_won": 0,
		"xp": 0,
		"level": 1,
		"achievements": [],
		"unlocked_themes": ["default"],
		"current_theme": "default",
		"stats": {
			"extra_balls_bought": 0,
			"near_wins": 0,
			"biggest_win": 0,
			"current_streak": 0,
			"best_streak": 0,
			"total_numbers_drawn": 0
		}
	}

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_game()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_deep_merge(player_data, json.get_data())
	file.close()

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: não foi possível gravar save")
		return
	file.store_string(JSON.stringify(player_data, "\t"))
	file.close()

# --- API pública ---

func get_coins() -> int:
	return player_data.get("coins", 0)

func spend_coins(amount: int) -> bool:
	if player_data["coins"] < amount:
		GameEvents.insufficient_funds.emit()
		return false
	player_data["coins"] -= amount
	player_data["total_spent"] += amount
	GameEvents.coins_changed.emit(player_data["coins"], -amount)
	save_game()
	return true

func add_coins(amount: int) -> void:
	player_data["coins"] += amount
	player_data["total_won"] += amount
	if amount > player_data["stats"]["biggest_win"]:
		player_data["stats"]["biggest_win"] = amount
	GameEvents.coins_changed.emit(player_data["coins"], amount)
	save_game()

func add_xp(amount: int) -> void:
	player_data["xp"] += amount
	GameEvents.xp_gained.emit(amount, player_data["xp"])

	var xp_per_level: int = ConfigLoader.get_value("progression.xp_per_level", 200)
	var new_level: int = int(player_data["xp"] / xp_per_level) + 1
	if new_level > player_data["level"]:
		player_data["level"] = new_level
		GameEvents.level_up.emit(new_level)
	save_game()

func unlock_achievement(id: String) -> void:
	if id in player_data["achievements"]:
		return
	player_data["achievements"].append(id)
	GameEvents.achievement_unlocked.emit(id)
	save_game()

func get_level() -> int:
	return player_data.get("level", 1)

func get_xp_progress() -> float:
	var xp_per_level: int = ConfigLoader.get_value("progression.xp_per_level", 200)
	return fmod(float(player_data["xp"]), float(xp_per_level)) / float(xp_per_level)

# --- Internos ---

func _deep_merge(base: Dictionary, override: Dictionary) -> void:
	for key in override:
		if base.has(key) and typeof(base[key]) == TYPE_DICTIONARY and typeof(override[key]) == TYPE_DICTIONARY:
			_deep_merge(base[key], override[key])
		else:
			base[key] = override[key]
