class_name Player extends CharacterBody2D

# --- Physics Constants ---
@export var moveSpeed : float = 150.0

@export var jumpHeight : float = 40.0
@export var jumpTime2Peak : float = 0.35
@export var jumpTime2Descent : float = 0.25

# We calculate these only once when the game starts
@onready var jumpVelocity : float = ((2.0 * jumpHeight) / jumpTime2Peak) * -1.0
@onready var jumpGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Peak * jumpTime2Peak)) * -1.0
@onready var fallGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Descent * jumpTime2Descent)) * -1.0

# --- Animation/State ---
var state : String = "IDLE"
var updateAnimation : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	return

func _physics_process(delta: float) -> void:
	# Apply Gravity (Add to existing Y velocity, don't replace it)
	velocity.y += GetGravity() * delta

	# Get Horizontal Input (Walk)
	# This replaces your old "direction" logic for X movement
	var input_axis = Input.get_axis("left", "right")
	velocity.x = input_axis * moveSpeed

	# Handle Jump Input
	# We use "is_action_just_pressed" so you don't bunny hop if you hold the button
	if Input.is_action_just_pressed("up") and is_on_floor():
		Jump()

	# Move
	move_and_slide()

	# Handle Animation States
	UpdateState(input_axis)
	if updateAnimation:
		UpdateAnimation()

func GetGravity() -> float:
	# If we are moving up, we use jump gravity. If we are moving down, we use fall gravity.
	return jumpGravity if velocity.y < 0.0 else fallGravity

func Jump() -> void:
	velocity.y = jumpVelocity

func UpdateState(input_axis: float) -> void:
	# Handle Facing Direction
	if input_axis != 0:
		sprite.flip_h = input_axis < 0
	
	# Determine State based on Physics (Air vs Ground)
	var new_state = state

	if not is_on_floor():
		if velocity.y < 0:
			new_state = "JUMP"
		else:
			new_state = "FALLING"
	else:
		if input_axis != 0:
			# We are walking
			if input_axis > 0:
				new_state = "WALK_RIGHT" 
			else:
				new_state = "WALK_LEFT"
		else:
			new_state = "IDLE"

	# Only update if state actually changed
	if new_state != state:
		SetState(new_state)
		updateAnimation = true

func SetState(new_state : String) -> void:
	state = new_state

func UpdateAnimation() -> void:
	updateAnimation = false
	animation_player.play(state)
