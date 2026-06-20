extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# keybinds
@export var jump_action: StringName = "p1_jump"
@export var left_action: StringName = "p1_left"
@export var right_action: StringName = "p1_right"
@export var smol_action: StringName = "p1_smol"

# movement vars
# horizontal
@export var speed: float = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2400.0
@export var air_acceleration: float = 1200.0
@export var air_friction: float = 400.0
# jump
@export var jump_velocity: float = -400.0
# gravity
@export var rise_gravity_scale: float = 1.0
@export var fall_gravity_scale: float = 1.6
@export var max_fall_speed: float = 1000.0
# short tap -> short hop
# if you let go when going up, kinda like stop going up as much
@export_range(0.0, 1.0) var jump_cut_factor: float = 0.4
# coyote time! :D (and other buffer time)
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
# shrink toggle
const SCALE_FACTOR = 0.5

# timers
var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# make timers go
	_coyote_timer = coyote_time if on_floor else _coyote_timer - delta
	if Input.is_action_just_pressed(jump_action):
		_buffer_timer = jump_buffer_time
	else:
		_buffer_timer -= delta

	# do gravity
	if not on_floor:
		var grav_scale := fall_gravity_scale if velocity.y > 0.0 else rise_gravity_scale
		velocity += get_gravity() * grav_scale * delta
		velocity.y = minf(velocity.y, max_fall_speed)

	# jump (if buffered jump, allow coyote too)
	if _buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_buffer_timer = 0.0
		_coyote_timer = 0.0

	# stop going up as much when we let go
	if Input.is_action_just_released(jump_action) and velocity.y < 0.0:
		velocity.y *= jump_cut_factor

	# shrink / grow toggle
	if Input.is_action_just_pressed(smol_action):
		if scale.x == SCALE_FACTOR:
			scale = Vector2(1, 1)
		else:
			scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

	# horizontal movement
	var direction := Input.get_axis(left_action, right_action)
	if direction != 0.0:
		# horizontal move pressed
		var accel := acceleration if on_floor else air_acceleration
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
		anim.flip_h = direction < 0.0
	else:
		# not pressing move, slow down
		var fric := friction if on_floor else air_friction
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# magic godot function waow godot is so cool
	move_and_slide()
