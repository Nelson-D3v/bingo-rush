## Tela de título estilo bingo tradicional.
extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	# Fundo azul escuro
	var bg := ColorRect.new()
	bg.color = Color("#0D47A1")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Faixa decorativa amarela no topo e rodapé
	var stripe_top := _stripe()
	stripe_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	stripe_top.size.y = 12
	add_child(stripe_top)

	var stripe_bot := _stripe()
	stripe_bot.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	stripe_bot.size.y = 12
	stripe_bot.offset_top = -12
	add_child(stripe_bot)

	# Conteúdo centralizado
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)

	# Painel de título com borda amarela
	var title_panel := PanelContainer.new()
	var tsbox := StyleBoxFlat.new()
	tsbox.bg_color = Color("#1565C0")
	tsbox.set_border_width_all(4)
	tsbox.border_color = Color("#FBC02D")
	tsbox.set_corner_radius_all(6)
	title_panel.add_theme_stylebox_override("panel", tsbox)
	title_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(title_panel)

	var title_inner := VBoxContainer.new()
	title_inner.add_theme_constant_override("separation", 4)
	title_inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24)
	title_panel.add_child(title_inner)

	var logo := Label.new()
	logo.text = "BINGO RUSH"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 62)
	logo.add_theme_color_override("font_color", Color("#FBC02D"))
	title_inner.add_child(logo)

	var sub := Label.new()
	sub.text = "Videobingo  •  Partidas Rápidas  •  Decisões Reais"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.78, 0.88, 1.0))
	title_inner.add_child(sub)

	# Saldo
	var coins_lbl := Label.new()
	coins_lbl.text = "Seu saldo:  %d moedas" % SaveManager.get_coins()
	coins_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_lbl.add_theme_font_size_override("font_size", 22)
	coins_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
	vbox.add_child(coins_lbl)

	# Botão JOGAR
	var btn := Button.new()
	btn.text = "▶   J O G A R"
	btn.custom_minimum_size = Vector2(280, 74)
	btn.add_theme_font_size_override("font_size", 30)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var bsbox := StyleBoxFlat.new()
	bsbox.bg_color = Color("#C62828")
	bsbox.set_corner_radius_all(6)
	bsbox.set_border_width_all(3)
	bsbox.border_color = Color("#FF8A80")
	btn.add_theme_stylebox_override("normal", bsbox)
	var bhover := bsbox.duplicate() as StyleBoxFlat
	bhover.bg_color = Color("#E53935")
	btn.add_theme_stylebox_override("hover", bhover)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.pressed.connect(_launch)
	vbox.add_child(btn)

	# Versão
	var ver := Label.new()
	ver.text = "v%s" % ConfigLoader.get_value("version", "1.0")
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.add_theme_font_size_override("font_size", 12)
	ver.add_theme_color_override("font_color", Color(0.4, 0.5, 0.7))
	vbox.add_child(ver)

	# Animação suave do logo
	logo.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(logo, "modulate:a", 1.0, 0.9)

func _stripe() -> ColorRect:
	var r := ColorRect.new()
	r.color = Color("#FBC02D")
	return r

func _launch() -> void:
	get_tree().change_scene_to_packed(load("res://scenes/GameScreen.tscn"))
