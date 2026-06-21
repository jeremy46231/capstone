extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var _players: Array = [$Player, $Player2]
@onready var win_zone: Area2D = $WinZone

const FOCUS_FRACTION := 0.8
const CAM_SMOOTH := 8.0

const WIN_DWELL := 0.3
var _win_timer: float = 0.0
var _won: bool = false

# captured at start
var _default_zoom: float
var _min_x: float
var _fixed_y: float


func _ready() -> void:
	_default_zoom = camera.zoom.x
	_min_x = camera.global_position.x
	_fixed_y = camera.global_position.y


func _physics_process(delta: float) -> void:
	var alive := _players.filter(func(p): return is_instance_valid(p))
	if alive.is_empty():
		return

	# follow the midpoint x, clamped
	var sum_x := 0.0
	for p in alive:
		sum_x += p.global_position.x
	var center_x: float = maxf(sum_x / alive.size(), _min_x)
	var target_pos := Vector2(center_x, _fixed_y)

	# zoom out until every player fits
	var half := FOCUS_FRACTION * 0.5
	var view := get_viewport_rect().size
	var target_zoom := _default_zoom
	for p in alive:
		var dx: float = absf(p.global_position.x - center_x)
		var dy: float = absf(p.global_position.y - _fixed_y)
		if dx > 0.0:
			target_zoom = minf(target_zoom, view.x * half / dx)
		if dy > 0.0:
			target_zoom = minf(target_zoom, view.y * half / dy)

	# smooth toward the target
	var t := 1.0 - exp(-CAM_SMOOTH * delta)
	camera.global_position = camera.global_position.lerp(target_pos, t)
	camera.zoom = camera.zoom.lerp(Vector2(target_zoom, target_zoom), t)

	if not _won:
		_check_win(alive, delta)


# clear the level once every alive player is in the win zone together
func _check_win(alive: Array, delta: float) -> void:
	var in_zone := win_zone.get_overlapping_bodies().filter(func(b): return b is Player)
	if not alive.is_empty() and in_zone.size() == alive.size():
		_win_timer += delta
		if _win_timer >= WIN_DWELL:
			_level_complete()
	else:
		_win_timer = 0.0


func _level_complete() -> void:
	_won = true
	print("Level complete!")
	# TODO: load the next level instead of restarting
	get_tree().reload_current_scene()
