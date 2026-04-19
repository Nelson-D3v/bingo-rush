## Cartela 3×5 (15 números). Clicável antes do início para troca.
## Layout de células:
##   [00][01][02][03][04]
##   [05][06][07][08][09]
##   [10][11][12][13][14]
class_name BingoCard
extends PanelContainer

const ROWS := 3
const COLS := 5
const CELL_SZ := Vector2(62, 56)

const C_WHITE       := Color("#FFFFFF")
const C_BLACK       := Color("#000000")
const C_BLUE_HDR    := Color("#1565C0")
const C_RED_MARK    := Color("#C62828")
const C_CELL_LINE   := Color("#BDBDBD")
const C_MARKED_BG   := Color("#FFEBEE")
const C_NEAR_BG     := Color("#FFFDE7")
const C_NEAR_BORDER := Color("#FBC02D")
const C_WIN_BG      := Color("#E8F5E9")
const C_WIN_BORDER  := Color("#2E7D32")
const C_SWAP_BG     := Color("#E3F2FD")
const C_SWAP_BORDER := Color("#1565C0")

var card_id: int = 0
var _swap_mode: bool = false
var _cells: Array[Panel] = []

func _ready() -> void:
	custom_minimum_size = Vector2(COLS * CELL_SZ.x + 10, ROWS * CELL_SZ.y + 40)
	_apply_outer_style(false)
	_build_ui()
	GameEvents.card_number_marked.connect(_on_number_marked)
	GameEvents.pattern_completed.connect(_on_pattern_completed)

func setup(data: Dictionary) -> void:
	card_id = data["id"]
	var hdr := get_node_or_null("VBox/Header/Label") as Label
	if hdr:
		hdr.text = "CARTELA  %d" % (card_id + 1)
	for i in range(mini(_cells.size(), data["numbers"].size())):
		_num_lbl(i).text = str(data["numbers"][i])
	for idx in data["marked"]:
		_mark_cell(idx, false)

# ── Swap mode ─────────────────────────────────────────────────────────────────

func set_swap_mode(enabled: bool) -> void:
	_swap_mode = enabled
	_apply_outer_style(enabled)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW

func _on_mouse_entered() -> void:
	if _swap_mode:
		modulate = Color(0.88, 0.94, 1.0)

func _on_mouse_exited() -> void:
	if _swap_mode:
		modulate = Color.WHITE

func _gui_input(event: InputEvent) -> void:
	if not _swap_mode:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameEvents.card_swap_requested.emit(card_id)
		accept_event()

# ── Build ─────────────────────────────────────────────────────────────────────

func _apply_outer_style(swap: bool) -> void:
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = C_SWAP_BG if swap else C_WHITE
	sbox.set_corner_radius_all(3)
	sbox.set_border_width_all(2)
	sbox.border_color = C_SWAP_BORDER if swap else Color("#424242")
	add_theme_stylebox_override("panel", sbox)

func _build_ui() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 0)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 3)
	# IGNORE: eventos passam para o BingoCard (PanelContainer pai)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)

	# Header
	var header := Panel.new()
	header.name = "Header"
	header.custom_minimum_size.y = 28
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsbox := StyleBoxFlat.new()
	hsbox.bg_color = C_BLUE_HDR
	header.add_theme_stylebox_override("panel", hsbox)
	vbox.add_child(header)

	var hdr_lbl := Label.new()
	hdr_lbl.name = "Label"
	hdr_lbl.text = "CARTELA  1"
	hdr_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hdr_lbl.add_theme_font_size_override("font_size", 13)
	hdr_lbl.add_theme_color_override("font_color", C_WHITE)
	hdr_lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header.add_child(hdr_lbl)

	# Grade 3×5
	var grid := GridContainer.new()
	grid.columns = COLS
	grid.add_theme_constant_override("h_separation", 1)
	grid.add_theme_constant_override("v_separation", 1)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(grid)

	_cells.clear()
	for i in range(ROWS * COLS):
		var cell := _make_cell()
		grid.add_child(cell)
		_cells.append(cell)

	# Hover: conecta sinais de mouse para feedback de troca
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _make_cell() -> Panel:
	var cell := Panel.new()
	cell.custom_minimum_size = CELL_SZ
	# Eventos passam para BingoCard — sem isso o clique para na célula
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_cell_style(cell, C_WHITE, C_CELL_LINE, 1)

	var num := Label.new()
	num.name = "NumLabel"
	num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num.add_theme_font_size_override("font_size", 22)
	num.add_theme_color_override("font_color", C_BLACK)
	num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cell.add_child(num)

	var x := Label.new()
	x.name = "XLabel"
	x.text = "✕"
	x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	x.add_theme_font_size_override("font_size", 44)
	x.add_theme_color_override("font_color", C_RED_MARK)
	x.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	x.modulate.a = 0.0
	x.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(x)

	return cell

# ── Visuais ───────────────────────────────────────────────────────────────────

func _set_cell_style(cell: Panel, bg: Color, border: Color, w: int) -> void:
	var sbox := StyleBoxFlat.new()
	sbox.bg_color = bg
	sbox.set_border_width_all(w)
	sbox.border_color = border
	cell.add_theme_stylebox_override("panel", sbox)

func _num_lbl(i: int) -> Label:
	return _cells[i].get_node("NumLabel") as Label

func _x_lbl(i: int) -> Label:
	return _cells[i].get_node("XLabel") as Label

func _mark_cell(index: int, animate: bool = true) -> void:
	if index >= _cells.size():
		return
	var xlbl := _x_lbl(index)
	if xlbl.modulate.a > 0.5:
		return
	_set_cell_style(_cells[index], C_MARKED_BG, C_RED_MARK, 1)
	_num_lbl(index).add_theme_color_override("font_color", Color("#BDBDBD"))
	if animate:
		xlbl.scale = Vector2(1.6, 1.6)
		var tw := create_tween()
		tw.tween_property(xlbl, "modulate:a", 0.88, 0.12)
		tw.parallel().tween_property(xlbl, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)
	else:
		xlbl.modulate.a = 0.88

func highlight_winning_cells(cells: Array) -> void:
	for idx in cells:
		if idx < _cells.size():
			_set_cell_style(_cells[idx], C_WIN_BG, C_WIN_BORDER, 2)
			var tw := create_tween()
			tw.set_loops(4)
			tw.tween_property(_cells[idx], "modulate", Color(1.0, 1.4, 1.0), 0.14)
			tw.tween_property(_cells[idx], "modulate", Color.WHITE, 0.14)

func highlight_near_win_cells(cells: Array) -> void:
	for idx in cells:
		if idx < _cells.size():
			_set_cell_style(_cells[idx], C_NEAR_BG, C_NEAR_BORDER, 2)
			var tw := create_tween()
			tw.set_loops(6)
			tw.tween_property(_cells[idx], "modulate", Color(1.0, 1.0, 0.5), 0.20)
			tw.tween_property(_cells[idx], "modulate", Color.WHITE, 0.20)

func clear_near_win_highlight(marked_indices: Array) -> void:
	for i in range(_cells.size()):
		if not (i in marked_indices):
			_set_cell_style(_cells[i], C_WHITE, C_CELL_LINE, 1)
			_cells[i].modulate = Color.WHITE

# ── Refresca números após troca ───────────────────────────────────────────────

func refresh(data: Dictionary) -> void:
	# Reseta visuais e aplica novos dados
	for i in range(_cells.size()):
		_set_cell_style(_cells[i], C_WHITE, C_CELL_LINE, 1)
		_num_lbl(i).add_theme_color_override("font_color", C_BLACK)
		_x_lbl(i).modulate.a = 0.0
		_cells[i].modulate = Color.WHITE
	setup(data)

# ── Eventos ───────────────────────────────────────────────────────────────────

func _on_number_marked(cid: int, _number: int, cell_index: int) -> void:
	if cid == card_id:
		_mark_cell(cell_index)

func _on_pattern_completed(cid: int, _pattern_id: String, _reward: int) -> void:
	if cid != card_id:
		return
	var tw := create_tween()
	tw.set_loops(5)
	tw.tween_property(self, "modulate", Color(0.8, 1.4, 0.8), 0.18)
	tw.tween_property(self, "modulate", Color.WHITE, 0.18)
