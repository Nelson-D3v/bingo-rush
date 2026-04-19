## Popup de oferta de bola extra — estilo bingo tradicional.
## Countdown de 10s força decisão rápida (pressão emocional).
class_name ExtraBallDialog
extends CanvasLayer

const C_BG      := Color(0.0, 0.0, 0.0, 0.82)
const C_PANEL   := Color("#1565C0")
const C_BORDER  := Color("#FBC02D")
const C_YELLOW  := Color("#FBC02D")
const C_WHITE   := Color("#FFFFFF")
const C_GREEN   := Color("#1B5E20")
const C_RED_BTN := Color("#B71C1C")

var _gm: GameManager
var _cost: int = 0
var _countdown: int = 10
var _tick_timer: Timer
var _countdown_lbl: Label

func setup(cost: int, numbers_away: int, gm: GameManager) -> void:
	_cost = cost
	_gm = gm
	_build(cost, numbers_away)
	_start_countdown()

func _build(cost: int, away: int) -> void:
	# Fundo escuro
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Painel central
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(440, 310)
	panel.offset_left = -220
	panel.offset_top  = -155
	panel.offset_right = 220
	panel.offset_bottom = 155
	add_child(panel)

	var psbox := StyleBoxFlat.new()
	psbox.bg_color = C_PANEL
	psbox.set_corner_radius_all(6)
	psbox.set_border_width_all(3)
	psbox.border_color = C_BORDER
	panel.add_theme_stylebox_override("panel", psbox)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 14)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	panel.add_child(vbox)

	# Título
	var title := Label.new()
	title.text = "★  QUASE LÁ!  ★"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", C_YELLOW)
	vbox.add_child(title)

	# Separador
	var sep_line := Panel.new()
	sep_line.custom_minimum_size.y = 2
	var slsbox := StyleBoxFlat.new()
	slsbox.bg_color = Color(1.0, 1.0, 1.0, 0.3)
	sep_line.add_theme_stylebox_override("panel", slsbox)
	vbox.add_child(sep_line)

	# Descrição
	var away_labels: Array[String] = ["", "UM NÚMERO", "DOIS NÚMEROS", "TRÊS NÚMEROS"]
	var away_text: String = away_labels[mini(away, 3)]
	var desc := Label.new()
	desc.text = "Falta apenas %s para o BINGO!" % away_text
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 19)
	desc.add_theme_color_override("font_color", C_WHITE)
	vbox.add_child(desc)

	# Custo
	var cost_lbl := Label.new()
	cost_lbl.text = "Compre 1 bola extra por  %d moeda(s)" % cost
	cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_lbl.add_theme_font_size_override("font_size", 17)
	cost_lbl.add_theme_color_override("font_color", C_YELLOW)
	vbox.add_child(cost_lbl)

	# Saldo
	var bal := Label.new()
	bal.text = "Saldo atual: %d moedas" % SaveManager.get_coins()
	bal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bal.add_theme_font_size_override("font_size", 13)
	bal.add_theme_color_override("font_color", Color(0.8, 0.85, 1.0))
	vbox.add_child(bal)

	# Botões
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 18)
	vbox.add_child(hbox)

	var btn_sim := Button.new()
	btn_sim.text = "✔  COMPRAR  (%d)" % cost
	btn_sim.custom_minimum_size = Vector2(180, 54)
	btn_sim.add_theme_font_size_override("font_size", 17)
	_style_btn(btn_sim, C_GREEN)
	btn_sim.pressed.connect(_on_yes)
	hbox.add_child(btn_sim)

	var btn_nao := Button.new()
	btn_nao.text = "✖  DESISTIR"
	btn_nao.custom_minimum_size = Vector2(140, 54)
	btn_nao.add_theme_font_size_override("font_size", 17)
	_style_btn(btn_nao, C_RED_BTN)
	btn_nao.pressed.connect(_on_no)
	hbox.add_child(btn_nao)

	# Countdown
	_countdown_lbl = Label.new()
	_countdown_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_lbl.add_theme_font_size_override("font_size", 12)
	_countdown_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	vbox.add_child(_countdown_lbl)
	_update_countdown()

	# Entrada animada
	panel.scale = Vector2(0.5, 0.5)
	panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(panel, "modulate:a", 1.0, 0.18)

func _style_btn(btn: Button, bg: Color) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = bg
	n.set_corner_radius_all(5)
	n.set_border_width_all(2)
	n.border_color = Color(1.0, 1.0, 1.0, 0.35)
	btn.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = bg.lightened(0.2)
	btn.add_theme_stylebox_override("hover", h)
	btn.add_theme_color_override("font_color", Color.WHITE)

func _start_countdown() -> void:
	_tick_timer = Timer.new()
	_tick_timer.wait_time = 1.0
	_tick_timer.timeout.connect(_on_tick)
	add_child(_tick_timer)
	_tick_timer.start()

func _on_tick() -> void:
	_countdown -= 1
	_update_countdown()
	if _countdown <= 0:
		_on_no()

func _update_countdown() -> void:
	if _countdown_lbl:
		_countdown_lbl.text = "Fechando em %d segundo%s..." % [_countdown, "s" if _countdown != 1 else ""]

func _on_yes() -> void:
	_tick_timer.stop()
	if _gm:
		_gm.purchase_extra_ball()
	queue_free()

func _on_no() -> void:
	_tick_timer.stop()
	if _gm:
		_gm.decline_extra_ball()
	queue_free()
