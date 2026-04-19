## Sorteio progressivo: começa lento (0.30s) e acelera até 0.12s conforme avança.
class_name DrawManager
extends Node

signal draw_completed(drawn_numbers: Array)

var _drawn: Array[int] = []
var _pool: Array[int] = []
var _is_drawing: bool = false
var _turbo: bool = false

var _timer: Timer
var _total: int = 60
var _per_round: int = 30

func _ready() -> void:
	_total    = ConfigLoader.get_value("draw.total_numbers", 60)
	_per_round = ConfigLoader.get_value("draw.numbers_per_round", 30)

	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_tick)
	add_child(_timer)

func start_round() -> void:
	_drawn.clear()
	_pool.clear()
	for i in range(1, _total + 1):
		_pool.append(i)
	_pool.shuffle()
	_is_drawing = true
	_schedule()

func _schedule() -> void:
	var interval: float
	if _turbo:
		interval = ConfigLoader.get_value("draw.turbo_interval_seconds", 0.07)
	else:
		# Aceleração suave de start → end ao longo da rodada
		var progress := float(_drawn.size()) / float(maxi(_per_round - 1, 1))
		var slow: float = ConfigLoader.get_value("draw.draw_interval_start", 0.30)
		var fast: float = ConfigLoader.get_value("draw.draw_interval_end", 0.12)
		interval = lerpf(slow, fast, progress)
	_timer.wait_time = maxf(interval, 0.05)
	_timer.start()

func _tick() -> void:
	if not _is_drawing:
		return
	var number := _pool.pop_back() as int
	_drawn.append(number)
	GameEvents.number_drawn.emit(number)
	SaveManager.player_data["stats"]["total_numbers_drawn"] += 1

	if _drawn.size() >= _per_round:
		_is_drawing = false
		GameEvents.draw_sequence_complete.emit()
		draw_completed.emit(_drawn.duplicate())
	else:
		_schedule()

func draw_extra_ball() -> int:
	if _pool.is_empty():
		return -1
	var number := _pool.pop_back() as int
	_drawn.append(number)
	GameEvents.extra_ball_drawn.emit(number)
	return number

func set_turbo(enabled: bool) -> void:
	_turbo = enabled
	if enabled:
		GameEvents.turbo_mode_activated.emit()

func get_drawn() -> Array[int]:
	return _drawn.duplicate()

func get_remaining_count() -> int:
	return _pool.size()

func is_drawing() -> bool:
	return _is_drawing
