class_name Player
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const SCALE_FACTOR := 0.5

var is_smol := false;

@export var jump_action: StringName = "p1_jump"
@export var left_action: StringName = "p1_left"
@export var right_action: StringName = "p1_right"
@export var smol_action: StringName = "p1_smol"
@export var teleport_action: StringName = "p1_teleport"
@export var other_player: Player;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed(smol_action):
			is_smol = !is_smol;

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(left_action, right_action)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Handle shrinking
	if is_smol and scale.x == 1:
		scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
	elif !is_smol and scale.x != 1:
		scale = Vector2(1, 1)
	
	# Handle teleporting
	if Input.is_action_just_pressed(teleport_action) and anim.animation == "default":
		other_player.queue_free()
		anim.play("stacked")
	
	move_and_slide()
