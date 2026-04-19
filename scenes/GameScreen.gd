## Tela principal. Dois estados visuais:
##   SELEÇÃO: botões de quantidade + "Iniciar Bingo" + cartelas clicáveis para trocar
##   JOGO:    sorteio ativo, botões bloqueados, histórico de bolas
extends Control

const BingoCardScene := preload("res://scenes/components/BingoCard.tscn")
const HUDScene        := preload("res://scenes/ui/HUD.tscn")
const ExtraBallScene  := preload("res://scenes/ui/ExtraBallDialog.tscn")
const WinScene        := preload("res://scenes/ui/WinScreen.tscn")

const C_BG_DARK  := Color("#0D47A1")
const C_YELLOW   := Color("#FBC02D")
const C_WHITE    := Color("#FFFFFF")
const C_RED      := Color("#C62828")
const C_GREEN    := Color("#1B5E20")
const BALL_COLORS := [Color("#FBC02D"), Color("#1976D2"), Color("#C62828"), Color("#2E7D32")]

var _game_manager: GameManager

# Refs de UI
var _cards_container: VBoxContainer
var _card_nodes: Array[BingoCard] = []
var _ball_row: HBoxContainer
var _ball_scroll: ScrollContainer
var _status_label: Label
var _current_ball_panel: Panel
var _current_ball_label: Label
var _history_panel: PanelContainer
var _action_bar: HBoxContainer
var _count_btns: Array[Button] = []
var _start_btn: Button

func _ready() -> void:
	_game_manager = GameManager.new()
	_game_manager.name = "GameManager"
	add_child(_game_manager)
	_build_layout()
	_connect_events()
	_show_selection_ui()

# ── Layout ────────────────────────────────────────────────────────────────────

func _build_layout() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = C_BG_DARK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 4)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 6)
	add_child(root)

	root.add_child(HUDScene.instantiate())

	# Status
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 16)
	_status_label.add_theme_color_override("font_color", C_WHITE)
	_status_label.custom_minimum_size.y = 24
	root.add_child(_status_label)

	# Área central: painéis de padrão + cartelas
	var middle := HBoxContainer.new()
	middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	middle.add_theme_constant_override("separation", 6)
	root.add_child(middle)

	middle.add_child(_build_patterns_col(true))

	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 6)
	middle.add_child(center)

	# Bola atual
	_current_ball_panel = _build_current_ball()
	center.add_child(_current_ball_panel)

	# Cartelas com scroll
	var card_scroll := ScrollContainer.new()
	card_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	card_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	center.add_child(card_scroll)

	_cards_container = VBoxContainer.new()
	_cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_container.add_theme_constant_override("separation", 10)
	_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_scroll.add_child(_cards_container)

	middle.add_child(_build_patterns_col(false))

	# Histórico
	_history_panel = _build_history_panel()
	root.add_child(_history_panel)

	# Barra de ação
	_action_bar = _build_action_bar()
	root.add_child(_action_bar)

func _build_current_ball() -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size.y = 82
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color("#0A3880")
	sbox.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", sbox)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	panel.add_child(hbox)

	var ttl := Label.new()
	ttl.text = "NÚMERO DA VEZ"
	ttl.add_theme_font_size_override("font_size", 13)
	ttl.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0))
	ttl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(ttl)

	var ball := Panel.new()
	ball.name = "Ball"
	ball.custom_minimum_size = Vector2(64, 64)
	var bsbox := StyleBoxFlat.new()
	bsbox.bg_color = C_YELLOW
	bsbox.set_corner_radius_all(32)
	bsbox.set_border_width_all(3)
	bsbox.border_color = Color("#F57F17")
	ball.add_theme_stylebox_override("panel", bsbox)
	hbox.add_child(ball)

	_current_ball_label = Label.new()
	_current_ball_label.text = "--"
	_current_ball_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_current_ball_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_current_ball_label.add_theme_font_size_override("font_size", 30)
	_current_ball_label.add_theme_color_override("font_color", C_BG_DARK)
	_current_ball_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ball.add_child(_current_ball_label)

	return panel

func _build_history_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 62
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color("#0A3880")
	sbox.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", sbox)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4)
	panel.add_child(vbox)

	var ttl := Label.new()
	ttl.text = "HISTÓRICO"
	ttl.add_theme_font_size_override("font_size", 10)
	ttl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.9))
	vbox.add_child(ttl)

	_ball_scroll = ScrollContainer.new()
	_ball_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_ball_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_ball_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(_ball_scroll)

	_ball_row = HBoxContainer.new()
	_ball_row.add_theme_constant_override("separation", 4)
	_ball_row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_ball_scroll.add_child(_ball_row)

	return panel

func _build_action_bar() -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	hbox.custom_minimum_size.y = 66

	# Botões de quantidade
	var labels := ["1 CARTELA\n1 moeda", "2 CARTELAS\n2 moedas", "3 CARTELAS\n3 moedas", "4 CARTELAS\n4 moedas"]
	for i in range(4):
		var btn := Button.new()
		btn.text = labels[i]
		btn.custom_minimum_size = Vector2(130, 58)
		btn.add_theme_font_size_override("font_size", 13)
		_style_btn(btn, Color("#0D47A1"), Color("#1565C0"))
		var cnt := i + 1
		btn.pressed.connect(func(): _on_select_count(cnt))
		_count_btns.append(btn)
		hbox.add_child(btn)

	# Separador vertical
	var sep := Panel.new()
	sep.custom_minimum_size = Vector2(2, 50)
	sep.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ssbox := StyleBoxFlat.new()
	ssbox.bg_color = Color(1.0, 1.0, 1.0, 0.3)
	sep.add_theme_stylebox_override("panel", ssbox)
	hbox.add_child(sep)

	# Botão iniciar
	_start_btn = Button.new()
	_start_btn.text = "▶  INICIAR\n    BINGO"
	_start_btn.custom_minimum_size = Vector2(150, 58)
	_start_btn.add_theme_font_size_override("font_size", 16)
	_style_btn(_start_btn, C_RED, Color("#E53935"))
	_start_btn.pressed.connect(_on_start_bingo)
	_start_btn.visible = false
	hbox.add_child(_start_btn)

	return hbox

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

func _get_representative_cells(pat: Dictionary) -> Array:
	var cells_arr: Array = pat.get("cells", [])
	if cells_arr.is_empty():
		return []
	match str(pat.get("id", "")):
		"column":
			return cells_arr[mini(2, cells_arr.size() - 1)]
		"line":
			return cells_arr[mini(1, cells_arr.size() - 1)]
		_:
			return cells_arr[0]

func _build_patterns_col(easy_side: bool) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size.x = 160
	vbox.add_theme_constant_override("separation", 5)

	var patterns: Array = ConfigLoader.get_value("patterns", [])
	if patterns.is_empty():
		patterns = _builtin_patterns()
	var card_cost: int = ConfigLoader.get_value("economy.card_cost", 1)

	for pat in patterns:
		if (int(pat["difficulty"]) <= 2) != easy_side:
			continue
		vbox.add_child(_make_pattern_item(pat, card_cost))

	var filler := Control.new()
	filler.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(filler)
	return vbox

func _make_pattern_item(pat: Dictionary, card_cost: int) -> PanelContainer:
	var panel := PanelContainer.new()
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = Color("#0D3B7A")
	sbox.set_corner_radius_all(4)
	sbox.set_border_width_all(1)
	sbox.border_color = Color(1.0, 1.0, 1.0, 0.15)
	# Padding via content_margin — PanelContainer ignora anchor preset de filhos
	sbox.content_margin_left   = 6.0
	sbox.content_margin_right  = 6.0
	sbox.content_margin_top    = 6.0
	sbox.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", sbox)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 3)
	panel.add_child(inner)

	var name_lbl := Label.new()
	name_lbl.text = str(pat["name"])
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", C_WHITE)
	inner.add_child(name_lbl)

	# Mini grid 3×5
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	inner.add_child(grid)

	var cell_set := {}
	for idx in _get_representative_cells(pat):
		cell_set[int(idx)] = true

	for i in range(15):
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(22, 16)
		dot.color = Color("#FFFFFF") if cell_set.has(i) else Color(0.3, 0.45, 0.7, 0.5)
		grid.add_child(dot)

	var prize_lbl := Label.new()
	var mult: int = int(pat["reward_multiplier"])
	prize_lbl.text = "x%d  (+%d moedas)" % [mult, card_cost * mult]
	prize_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prize_lbl.add_theme_font_size_override("font_size", 10)
	prize_lbl.add_theme_color_override("font_color", C_YELLOW)
	inner.add_child(prize_lbl)

	return panel

func _style_btn(btn: Button, bg: Color, hover: Color) -> void:
	var n := StyleBoxFlat.new()
	n.bg_color = bg
	n.set_corner_radius_all(5)
	n.set_border_width_all(2)
	n.border_color = Color(1.0, 1.0, 1.0, 0.3)
	btn.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = hover
	btn.add_theme_stylebox_override("hover", h)
	var d := n.duplicate() as StyleBoxFlat
	d.bg_color = Color(0.25, 0.25, 0.25)
	btn.add_theme_stylebox_override("disabled", d)
	btn.add_theme_color_override("font_color", C_WHITE)

# ── Lógica de UI por fase ─────────────────────────────────────────────────────

func _show_selection_ui() -> void:
	_set_status("Escolha quantas cartelas deseja jogar", C_WHITE)
	_start_btn.visible = false
	for btn in _count_btns:
		btn.disabled = false
		btn.modulate = Color.WHITE

func _show_game_ui() -> void:
	_start_btn.visible = false
	for btn in _count_btns:
		btn.disabled = true
	_set_swap_mode_all(false)

# ── Handlers de ação ──────────────────────────────────────────────────────────

func _on_select_count(count: int) -> void:
	# Gera cartelas gratuitamente — nenhum botão é desabilitado
	_game_manager.prepare_cards(count)
	# Apenas destaque visual no botão selecionado (sem bloquear os outros)
	for i in range(_count_btns.size()):
		_count_btns[i].modulate = Color(1.0, 1.0, 0.55) if (i + 1 == count) else Color.WHITE

func _on_start_bingo() -> void:
	if not _game_manager.confirm_and_start():
		# Saldo insuficiente — mantém tudo desbloqueado, avisa e não altera nada
		_set_status("Saldo insuficiente!", C_RED)

# ── Eventos do jogo ───────────────────────────────────────────────────────────

func _connect_events() -> void:
	GameEvents.game_state_changed.connect(_on_state_changed)
	GameEvents.cards_prepared.connect(_on_cards_prepared)
	GameEvents.card_swap_requested.connect(_on_swap_requested)
	GameEvents.card_swapped.connect(_on_card_swapped)
	GameEvents.number_drawn.connect(_on_number_drawn)
	GameEvents.extra_ball_drawn.connect(_on_number_drawn)
	GameEvents.near_win_detected.connect(_on_near_win)
	GameEvents.extra_ball_offered.connect(_on_extra_ball_offered)
	GameEvents.pattern_completed.connect(_on_pattern_completed)
	GameEvents.reward_granted.connect(_on_reward_granted)
	GameEvents.round_ended.connect(_on_round_ended)
	GameEvents.special_event_triggered.connect(_on_special_event)
	GameEvents.insufficient_funds.connect(func(): _set_status("Saldo insuficiente!", C_RED))

func _on_state_changed(state: String) -> void:
	match state:
		"IDLE":
			_show_selection_ui()
		"CARD_SELECTION":
			pass  # tratado em _on_cards_prepared
		"DRAWING":
			_set_status("Sorteando números...", C_WHITE)
			_show_game_ui()
		"CHECKING_WIN":
			_set_status("Verificando...", C_WHITE)
		"EXTRA_BALL_OFFER":
			pass
		"REWARDING":
			_set_status("BINGO!", C_YELLOW)

func _on_cards_prepared(count: int) -> void:
	call_deferred("_spawn_card_nodes", count)

func _spawn_card_nodes(count: int) -> void:
	_clear_cards()
	var cards_data := _game_manager.card_manager.get_cards()

	if count <= 2:
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_cards_container.add_child(row)
		for card_data in cards_data:
			var node := BingoCardScene.instantiate() as BingoCard
			row.add_child(node)
			node.setup(card_data)
			_card_nodes.append(node)
	elif count == 3:
		var row1 := HBoxContainer.new()
		row1.alignment = BoxContainer.ALIGNMENT_CENTER
		row1.add_theme_constant_override("separation", 10)
		row1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_cards_container.add_child(row1)
		var row2 := HBoxContainer.new()
		row2.alignment = BoxContainer.ALIGNMENT_CENTER
		row2.add_theme_constant_override("separation", 10)
		row2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_cards_container.add_child(row2)
		for i in range(cards_data.size()):
			var node := BingoCardScene.instantiate() as BingoCard
			(row1 if i < 2 else row2).add_child(node)
			node.setup(cards_data[i])
			_card_nodes.append(node)
	else:
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_cards_container.add_child(grid)
		for card_data in cards_data:
			var node := BingoCardScene.instantiate() as BingoCard
			grid.add_child(node)
			node.setup(card_data)
			_card_nodes.append(node)

	_set_swap_mode_all(true)
	_start_btn.visible = true
	for btn in _count_btns:
		btn.disabled = false
	_set_status("Clique numa cartela para trocá-la  |  clique INICIAR BINGO para começar", C_YELLOW)

func _on_swap_requested(card_id: int) -> void:
	# Anima feedback visual na cartela antes de trocar
	var node := _find_card(card_id)
	if node:
		var tw := create_tween()
		tw.tween_property(node, "modulate", Color(0.6, 0.6, 1.0), 0.08)
		tw.tween_property(node, "modulate", Color.WHITE, 0.08)
	_game_manager.swap_card(card_id)

func _on_card_swapped(card_id: int) -> void:
	var node := _find_card(card_id)
	if not node:
		return
	var new_data := _game_manager.card_manager.get_card(card_id)
	node.refresh(new_data)
	node.set_swap_mode(true)  # mantém clicável após troca
	# Pulso de confirmação — botões de contagem NÃO são tocados
	var tw := create_tween()
	tw.tween_property(node, "modulate", Color(0.7, 1.0, 0.7), 0.12)
	tw.tween_property(node, "modulate", Color.WHITE, 0.15)

func _on_number_drawn(number: int) -> void:
	_current_ball_label.text = str(number)
	var ball := _current_ball_panel.get_node("Ball") as Panel
	if ball:
		ball.scale = Vector2(1.35, 1.35)
		var tw := create_tween()
		tw.tween_property(ball, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)
	_add_ball_to_history(number)

func _on_near_win(_card_id: int, _pattern_id: String, numbers_away: int) -> void:
	var msg := "QUASE! Falta %d número!" % numbers_away if numbers_away == 1 \
			else "QUASE! Faltam %d números!" % numbers_away
	_set_status(msg, C_YELLOW)
	var tw := create_tween()
	tw.set_loops(8)
	tw.tween_property(_status_label, "modulate", Color(1.0, 0.5, 0.1), 0.25)
	tw.tween_property(_status_label, "modulate", Color.WHITE, 0.25)
	for nw in _game_manager.current_near_wins:
		var n := _find_card(nw["card_id"])
		if n:
			n.highlight_near_win_cells(nw["missing_cells"])

func _on_extra_ball_offered(cost: int, numbers_away: int) -> void:
	var d := ExtraBallScene.instantiate() as ExtraBallDialog
	add_child(d)
	d.setup(cost, numbers_away, _game_manager)

func _on_pattern_completed(card_id: int, _pattern_id: String, _reward: int) -> void:
	for win in _game_manager.current_wins:
		if win["card_id"] == card_id:
			var n := _find_card(card_id)
			if n:
				n.highlight_winning_cells(win["winning_cells"])

func _on_reward_granted(amount: int, _reason: String) -> void:
	var ws := WinScene.instantiate() as WinScreen
	add_child(ws)
	ws.setup(amount)

func _on_round_ended(_won: bool) -> void:
	_status_label.modulate = Color.WHITE
	_clear_balls()
	_current_ball_label.text = "--"

func _on_special_event(event_type: String) -> void:
	match event_type:
		"multiplier": _set_status("✦ MULTIPLICADOR ATIVO!", C_YELLOW)
		"turbo":      _set_status("⚡ RODADA TURBO!", C_YELLOW)
		"bonus_ball": _set_status("★ BOLA BÔNUS GRÁTIS!", C_YELLOW)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _set_status(text: String, color: Color) -> void:
	_status_label.text = text
	_status_label.modulate = Color.WHITE
	_status_label.add_theme_color_override("font_color", color)

func _set_swap_mode_all(enabled: bool) -> void:
	for c in _card_nodes:
		c.set_swap_mode(enabled)

func _add_ball_to_history(number: int) -> void:
	var ball := Panel.new()
	ball.custom_minimum_size = Vector2(40, 40)
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = BALL_COLORS[mini((number - 1) / 15, 3)]
	sbox.set_corner_radius_all(20)
	sbox.set_border_width_all(2)
	sbox.border_color = Color(0, 0, 0, 0.35)
	ball.add_theme_stylebox_override("panel", sbox)
	var lbl := Label.new()
	lbl.text = str(number)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", C_WHITE)
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ball.add_child(lbl)
	_ball_row.add_child(ball)
	ball.scale = Vector2(0.2, 0.2)
	ball.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(ball, "scale", Vector2(1.1, 1.1), 0.13).set_trans(Tween.TRANS_BACK)
	tw.tween_property(ball, "scale", Vector2.ONE, 0.07)
	tw.parallel().tween_property(ball, "modulate:a", 1.0, 0.13)
	await get_tree().process_frame
	_ball_scroll.scroll_horizontal = _ball_scroll.get_h_scroll_bar().max_value

func _clear_balls() -> void:
	for c in _ball_row.get_children():
		c.queue_free()

func _clear_cards() -> void:
	_card_nodes.clear()
	for c in _cards_container.get_children():
		c.queue_free()

func _find_card(card_id: int) -> BingoCard:
	for bc in _card_nodes:
		if bc.card_id == card_id:
			return bc
	return null
