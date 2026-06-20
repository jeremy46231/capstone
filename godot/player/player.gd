extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $/AnimatedSprite2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const SCALE_FACTOR = 0.5

@export var jump_action: StringName = "p1_jump"
@export var left_action: StringName = "p1_left"
@export var right_action: StringName = "p1_right"
@export var smol_action: StringName = "p1_smol"

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle shrinking
	if Input.is_action_just_pressed(smol_action):
			#scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
			if scale.x == SCALE_FACTOR:
				scale = Vector2(1, 1)
			else: 
				scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis(left_action, right_action)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
