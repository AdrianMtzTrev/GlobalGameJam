class_name Player extends CharacterBody2D

# CONSTANTS
const HEARTS_MASKS : int = 3
const HEARTS_MASKS_RESITANCE : int = 2
const RUN_SPEED : float = 150.0
const DAMAGE : float = 1

# --- Physics Constants ---
@export var moveSpeed : float = 150.0
@export var jumpHeight : float = 45.0
@export var jumpTime2Peak : float = 0.35
@export var jumpTime2Descent : float = 0.25

# We calculate these only once when the game starts
@onready var jumpVelocity : float = ((2.0 * jumpHeight) / jumpTime2Peak) * -1.0
@onready var jumpGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Peak * jumpTime2Peak)) * -1.0
@onready var fallGravity : float = ((-2.0 * jumpHeight) / (jumpTime2Descent * jumpTime2Descent)) * -1.0

# Health
var health : int = HEARTS_MASKS * HEARTS_MASKS_RESITANCE
signal signal_healthChanged(health)

# --- Animation/State ---
var state : String = "IDLE"
var updateAnimation : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var playerSprite : Sprite2D = $PlayerSprite

# --- LEDGE SENSOR ---
@onready var ledge_check : Node2D = $LedgeGrab
@onready var wall_check : ShapeCast2D = $WallCheck

func _ready() -> void:
	# Safety: If using ShapeCast2D, ignore own body
	if ledge_check is ShapeCast2D:
		ledge_check.add_exception(self)
	
	# Optional: Force collision mask to Layer 1 (World) only
	# wall_check.collision_mask = 1 

func _physics_process(delta: float) -> void:
	if !isAlive():
		SetState("DEATH")
		UpdateAnimation()
		state = ""
		return
		
	var input_axis = Input.get_axis("left", "right")

	# 1. Flip Directions (LOCKED while grabbing, attacking or hurt)
	if state != "EDGE_GRAB" and state != "ATTACK" and state != "HURT":
		if input_axis != 0:
			playerSprite.flip_h = input_axis < 0
			ledge_check.scale.x = input_axis 

	# 2. State Logic
	if state == "EDGE_GRAB":
		# --- GRAB BEHAVIOR ---
		velocity = Vector2.ZERO 
		
		if Input.is_action_just_pressed("up"):
			Jump()
			state = "JUMP"
		
		if Input.is_action_just_pressed("down"):
			state = "FALLING"
			position.y += 5 
	
	# --- FREEZE LOGIC ---
	elif state == "ATTACK" or state == "HURT":
		velocity.x = 0 # Freeze horizontal movement
		velocity.y += GetGravity() * delta # Keep gravity
		
	else:
		# --- NORMAL BEHAVIOR ---
		velocity.y += GetGravity() * delta
		velocity.x = input_axis * moveSpeed
		
		if Input.is_action_just_pressed("up") and is_on_floor():
			Jump()

		# --- LEDGE DETECTION LOGIC ---
		if not is_on_floor() and velocity.y > 0:
			if wall_check.is_colliding() and not ledge_check.is_colliding():
				state = "EDGE_GRAB"
				updateAnimation = true
				
				# Snap Fix
				var wall_direction = get_wall_normal().x 
				position.x -= wall_direction * 4 

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
	# --- SPECIAL CHECKS (LOCKS) ---
	if state == "EDGE_GRAB": return
	if state == "ATTACK": return
	if state == "HURT": return

	# 1. TRIGGER ATTACK (NEW!)
	# Check this BEFORE movement so you can attack anytime
	if Input.is_action_just_pressed("attack"): # Make sure "attack" is in Input Map
		SetState("ATTACK")
		return
	# --- TAUNT LOCK ---
	if state == "TAUNT":
		if input_axis != 0: pass # Break taunt on move
		else: return # Wait for anim
	

	# --- MAIN MOVEMENT LOGIC ---
	var new_state = state

	if not is_on_floor():
		# AIR LOGIC
		if velocity.y < 0:
			new_state = "JUMP"
		else:
			new_state = "FALLING"
	else:
		# GROUND LOGIC
		if state == "FALLING": 
			if input_axis == 0:
				new_state = "LAND" 
			else:
				new_state = "RUN"
		
		elif input_axis != 0 and abs(velocity.x) > 5.0:
			new_state = "RUN"
		else:
			# WE ARE NOT MOVING (Input is 0)
			if state == "RUN":
				new_state = "TAUNT" 
			elif state != "LAND" and state != "TAUNT":
				new_state = "IDLE"

	if new_state != state:
		SetState(new_state)

func SetState(new_state : String) -> void:
	state = new_state
	updateAnimation = true
	# print(state) # Debug print

func UpdateAnimation() -> void:
	updateAnimation = false
	animation_player.play(state)

func TakeDamage():
	SetState("HURT")
	health -= 1
	signal_healthChanged.emit(health) 

func isAlive():
	return health > 0

# --- SIGNALS ---

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Reset to IDLE after one-shot animations
	if anim_name == "LAND" or anim_name == "TAUNT" or anim_name == "ATTACK" or anim_name == "HURT":
		SetState("IDLE")
		
	if anim_name == "DEATH":
		playerSprite.visible = false
		SetState("IDLE")
		await Fade.fade_to_black(0.25)
		get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
