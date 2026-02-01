class_name Player extends CharacterBody2D

# CONSTANTS
const HEARTS_MASKS : int = 3
const HEARTS_MASKS_RESITANCE : int = 2
const RUN_SPEED : float = 150.0
const DAMAGE : float = 1

# --- Physics Constants ---
@export var moveSpeed : float = 150.0

@export var jumpHeight : float = 40.0
@export var jumpTime2Peak : float = 0.35
@export var jumpTime2Descent : float = 0.25

# We calculate these only once when the game starts
@onready var jumpVelocity : float = ((2.0 * jumpHeight) / jumpTime2Peak) * -1.0
@onready var jumpGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Peak * jumpTime2Peak)) * -1.0
@onready var fallGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Descent * jumpTime2Descent)) * -1.0

# Health
var health : int = 100
signal signal_healthChanged(health)

# --- Animation/State ---
var state : String = "IDLE"
var updateAnimation : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var playerSprite : Sprite2D = $PlayerSprite

# --- LEDGE SENSOR ---
# PLEASE CHANGE YOUR NODE TYPE TO ShapeCast2D or RayCast2D
@onready var ledge_check : Node2D = $LedgeGrab
@onready var wall_check : ShapeCast2D = $WallCheck

func _ready() -> void:
	# Safety: If using ShapeCast2D, ignore own body
	if ledge_check is ShapeCast2D:
		ledge_check.add_exception(self)

func _physics_process(delta: float) -> void:
	if !isAlive():
		return
	var input_axis = Input.get_axis("left", "right")
	# 1. Flip Directions (LOCKED while grabbing)
	if state != "EDGE_GRAB":
		if input_axis != 0:
			playerSprite.flip_h = input_axis < 0
			# Flip the sensor too!
			ledge_check.scale.x = input_axis 
	# 2. State Logic
	if state == "EDGE_GRAB":
		# --- GRAB BEHAVIOR ---
		velocity = Vector2.ZERO # Stop falling
		
		# Climb Up
		if Input.is_action_just_pressed("up"):
			Jump()
			state = "JUMP"
		
		# Drop Down
		if Input.is_action_just_pressed("down"):
			state = "FALLING"
			position.y += 5 # Push down slightly
			
	else:
		# --- NORMAL BEHAVIOR ---
		velocity.y += GetGravity() * delta
		velocity.x = input_axis * moveSpeed
		if Input.is_action_just_pressed("up") and is_on_floor():
			Jump()
		# --- LEDGE DETECTION LOGIC ---
		# 1. Must be in air and falling
		# 2. Body must be touching a wall (is_on_wall)
		# 3. Head sensor must be clear (not is_colliding)
		if not is_on_floor() and velocity.y > 0:
			# Check if we found a ledge
			if wall_check.is_colliding() and not ledge_check.is_colliding():
				state = "EDGE_GRAB"
				updateAnimation = true
				
				# --- THE SNAP FIX ---
				# 1. Get the wall direction (Is it to my Right or Left?)
				var wall_direction = get_wall_normal().x 
				
				# 2. "get_wall_normal" points AWAY from the wall (e.g. -1 if wall is on Right)
				# So we subtract it to move TOWARDS the wall.
				position.x -= wall_direction * 4 # <--- Adjust '4' to fit your gap size!

	# Move
	move_and_slide()

	# Handle Animation States
	UpdateState(input_axis)
	if updateAnimation:
		UpdateAnimation()

func GetGravity() -> float:
	if state == "EDGE_GRAB": 
		return 0.0
	return jumpGravity if velocity.y < 0.0 else fallGravity

func Jump() -> void:
	velocity.y = jumpVelocity

func UpdateState(input_axis: float) -> void:
	# If grabbing, don't let Run/Idle override it
	if state == "EDGE_GRAB":
		return

	# Handle Facing Direction Visuals
	if input_axis != 0:
		playerSprite.flip_h = input_axis < 0
	
	# Determine State based on Physics (Air vs Ground)
	var new_state = state

	if not is_on_floor():
		if velocity.y < 0:
			new_state = "JUMP"
		else:
			new_state = "FALLING"
	else:
		if input_axis != 0 and abs(velocity.x) > 5.0:
			if input_axis > 0:
				new_state = "RUN" 
			else:
				new_state = "RUN"
		else:
			# We are either not pressing keys OR pushing a wall
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

func TakeDamage():
	health -= 1
	signal_healthChanged.emit(health) 

func isAlive():
	return health > 0


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
