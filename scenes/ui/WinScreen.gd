## Tela de vitória estilo bingo tradicional. Auto-fecha em 5s.
class_name WinScreen
extends CanvasLayer

const C_BLUE   := Color("#1565C0")
const C_YELLOW := Color("#FBC02D")
const C_WHITE  := Color("#FFFFFF")
const C_GREEN  := Color("#1B5E20")

func setup(amount: int) -> void:
	_build(amount)

func _build(amount: int) -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.78)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 340)
	panel.offset_left   = -240
	panel.offset_top    = -170
	panel.offset_right  = 240
	panel.offset_bottom = 170
	add_child(panel)

	var psbox := StyleBoxFlat.new()
	psbox.bg_color = C_BLUE
	psbox.set_corner_radius_all(8)
	psbox.set_border_width_all(4)
	psbox.border_color = C_YELLOW
	panel.add_theme_stylebox_override("panel", psbox)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 28)
	panel.add_child(vbox)

	# Cabeçalho amarelo
	var header := Panel.new()
	header.custom_minimum_size.y = 52
	var hsbox := StyleBoxFlat.new()
	hsbox.bg_color = C_YELLOW
	hsbox.set_corner_radius_all(4)
	header.add_theme_stylebox_override("panel", hsbox)
	vbox.add_child(header)

	var title := Label.new()
	title.text = "B I N G O !"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color("#0D47A1"))
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header.add_child(title)

	# Prêmio
	var prize := Label.new()
	prize.text = "+ %d moedas" % amount
	prize.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prize.add_theme_font_size_override("font_size", 36)
	prize.add_theme_color_override("font_color", Color("#69F0AE"))
	vbox.add_child(prize)

	# Stats
	var pd := SaveManager.player_data
	var streak: int = pd["stats"]["current_streak"]
	var biggest: int = pd["stats"]["biggest_win"]

	var stats := Label.new()
	stats.text = "Nível %d  |  Sequência %d  |  Melhor prêmio: %d" % [pd["level"], streak, biggest]
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.add_theme_font_size_override("font_size", 14)
	stats.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0))
	vbox.add_child(stats)

	# Botão
	var btn := Button.new()
	btn.text = "CONTINUAR"
	btn.custom_minimum_size = Vector2(200, 54)
	btn.add_theme_font_size_override("font_size", 20)
	var bsbox := StyleBoxFlat.new()
	bsbox.bg_color = C_GREEN
	bsbox.set_corner_radius_all(5)
	bsbox.set_border_width_all(2)
	bsbox.border_color = Color(1.0, 1.0, 1.0, 0.3)
	btn.add_theme_stylebox_override("normal", bsbox)
	btn.add_theme_color_override("font_color", C_WHITE)
	btn.pressed.connect(queue_free)
	vbox.add_child(btn)

	# Animação de entrada
	panel.scale = Vector2(0.2, 0.2)
	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(panel, "scale", Vector2(1.04, 1.04), 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.10)
	tw.parallel().tween_property(panel, "modulate:a", 1.0, 0.22)

	# Auto-fecha
	var t := Timer.new()
	t.wait_time = 5.0
	t.one_shot = true
	t.timeout.connect(queue_free)
	add_child(t)
	t.start()
