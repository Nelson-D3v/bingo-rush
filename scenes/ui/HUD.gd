## HUD estilo bingo tradicional: saldo, nível, rodadas, evento ativo.
class_name HUD
extends PanelContainer

const C_BLUE   := Color("#1565C0")
const C_YELLOW := Color("#FBC02D")
const C_WHITE  := Color("#FFFFFF")
const C_BLACK  := Color("#000000")

var _coins_label: Label
var _level_label: Label
var _rounds_label: Label
var _xp_bar: ProgressBar
var _event_label: Label

func _ready() -> void:
	custom_minimum_size.y = 36
	_apply_style()
	_build_ui()
	_connect_events()

func _apply_style() -> void:
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = C_BLUE
	sbox.border_width_bottom = 2
	sbox.border_color = Color("#0D47A1")
	add_theme_stylebox_override("panel", sbox)

func _build_ui() -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	add_child(hbox)

	# Saldo — "SALDO: 100"
	hbox.add_child(_lbl("SALDO:", 13, Color(0.75, 0.85, 1.0)))
	_coins_label = _lbl("100", 16, C_YELLOW)
	hbox.add_child(_coins_label)

	_sep(hbox)

	# Rodadas — "RODADAS: 0"
	hbox.add_child(_lbl("RODADAS:", 13, Color(0.75, 0.85, 1.0)))
	_rounds_label = _lbl("0", 16, C_WHITE)
	hbox.add_child(_rounds_label)

	_sep(hbox)

	# Nível + XP bar inline
	_level_label = _lbl("NÍVEL 1", 13, C_WHITE)
	hbox.add_child(_level_label)

	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(70, 8)
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_xp_bar.max_value = 1.0
	_xp_bar.value = 0.0
	_xp_bar.show_percentage = false
	hbox.add_child(_xp_bar)

	# Spacer
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sp)

	# Evento ativo
	_event_label = _lbl("", 15, C_YELLOW)
	_event_label.visible = false
	hbox.add_child(_event_label)

	_refresh()

func _lbl(text: String, font_size: int, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return lbl

func _sep(parent: HBoxContainer) -> void:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(1, 20)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color(1.0, 1.0, 1.0, 0.25)
	line.add_theme_stylebox_override("panel", sbox)
	parent.add_child(line)

func _refresh() -> void:
	_coins_label.text = str(SaveManager.get_coins())
	_level_label.text = "NÍVEL %d" % SaveManager.get_level()
	_xp_bar.value = SaveManager.get_xp_progress()
	_rounds_label.text = str(SaveManager.player_data.get("rounds_played", 0))

func _connect_events() -> void:
	GameEvents.coins_changed.connect(_on_coins)
	GameEvents.level_up.connect(_on_level_up)
	GameEvents.xp_gained.connect(func(_a, _b): _xp_bar.value = SaveManager.get_xp_progress())
	GameEvents.multiplier_activated.connect(func(m): _show_event("✦ x%.1f!" % m))
	GameEvents.special_event_triggered.connect(_on_event)
	GameEvents.round_ended.connect(func(_w): _rounds_label.text = str(SaveManager.player_data.get("rounds_played", 0)))

func _on_coins(balance: int, delta: int) -> void:
	_coins_label.text = str(balance)
	_coins_label.modulate = Color(0.4, 1.0, 0.4) if delta > 0 else Color(1.0, 0.4, 0.4)
	var tw := create_tween()
	tw.tween_property(_coins_label, "modulate", C_YELLOW, 0.5)

func _on_level_up(level: int) -> void:
	_level_label.text = "NÍVEL %d" % level
	_show_event("▲ NÍVEL %d!" % level)

func _on_event(event_type: String) -> void:
	match event_type:
		"turbo":      _show_event("⚡ TURBO!")
		"bonus_ball": _show_event("★ BOLA BÔNUS!")

func _show_event(text: String) -> void:
	_event_label.text = text
	_event_label.visible = true
	await get_tree().create_timer(3.0).timeout
	_event_label.visible = false
