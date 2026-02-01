class_name Player extends CharacterBody2D

# CONSTANTS
const HEARTS_MASKS : int = 3
const HEARTS_MASKS_RESITANCE : int = 2
const DAMAGE : float = 1

# --- Physics Constants ---
@export var moveSpeed : float = 150.0
@export var jumpHeight : float = 48.0
@export var jumpTime2Peak : float = 0.35
@export var jumpTime2Descent : float = 0.25

# --- DASH CONSTANTS (NUEVO) ---
@export var dashSpeed : float = 400.0   # Velocidad del impulso
@export var dashDuration : float = 0.2  # Duración en segundos

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

# --- Dash Variables ---
var dashTimer : float = 0.0
var canDash : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var playerSprite : Sprite2D = $PlayerSprite

# --- LEDGE SENSOR ---
@onready var ledge_check : Node2D = $LedgeGrab
@onready var wall_check : ShapeCast2D = $WallCheck

func _ready() -> void:
	# Safety: If using ShapeCast2D, ignore own body
	if ledge_check is ShapeCast2D:
		ledge_check.add_exception(self)

func _physics_process(delta: float) -> void:
	if !isAlive():
		SetState("DEATH")
		UpdateAnimation()
		state = ""
		return
		
	var input_axis = Input.get_axis("left", "right")

	# 1. Flip Directions (BLOQUEADO en Grab, Attack, Hurt y DASH)
	if state != "EDGE_GRAB" and state != "ATTACK" and state != "HURT" and state != "DASH":
		if input_axis != 0:
			playerSprite.flip_h = input_axis < 0
			ledge_check.scale.x = input_axis 

	# 2. State Logic
	if state == "EDGE_GRAB":
		velocity = Vector2.ZERO 
		if Input.is_action_just_pressed("up"):
			Jump()
			state = "JUMP"
			canDash = true # Al saltar del muro, recuperamos el dash
		if Input.is_action_just_pressed("down"):
			state = "FALLING"
			position.y += 5 
	
	# --- DASH LOGIC (NUEVO) ---
	elif state == "DASH":
		# Moverse recto en la dirección que mira el sprite
		var direction = -1 if playerSprite.flip_h else 1
		velocity.x = direction * dashSpeed
		velocity.y = 0 # Gravedad 0 para un dash recto aéreo
		
		# Temporizador
		dashTimer -= delta
		if dashTimer <= 0:
			SetState("FALLING") # Termina el dash
			velocity.x = 0      # Frenamos un poco
			
	# --- FREEZE LOGIC ---
	elif state == "ATTACK" or state == "HURT":
		velocity.x = 0 
		velocity.y += GetGravity() * delta 
		
	else:
		# --- NORMAL BEHAVIOR ---
		velocity.y += GetGravity() * delta
		velocity.x = input_axis * moveSpeed
		
		if Input.is_action_just_pressed("up") and is_on_floor():
			Jump()

		# Recargar Dash al tocar el suelo
		if is_on_floor():
			canDash = true

		# --- LEDGE DETECTION LOGIC ---
		if not is_on_floor() and velocity.y > 0:
			if wall_check.is_colliding() and not ledge_check.is_colliding():
				state = "EDGE_GRAB"
				updateAnimation = true
				canDash = true # Opcional: recargar dash al agarrarse
				var wall_direction = get_wall_normal().x 
				position.x -= wall_direction * 4 

	# Move
	move_and_slide()

	# Handle Animation States
	UpdateState(input_axis)
	if updateAnimation:
		UpdateAnimation()

func GetGravity() -> float:
	if state == "EDGE_GRAB": return 0.0
	return jumpGravity if velocity.y < 0.0 else fallGravity

func Jump() -> void:
	velocity.y = jumpVelocity

func StartDash():
	SetState("DASH")
	dashTimer = dashDuration
	canDash = false # Gastamos el uso

func UpdateState(input_axis: float) -> void:
	# --- HARD LOCKS ---
	if state == "EDGE_GRAB": return
	if state == "ATTACK": return
	if state == "HURT": return
	if state == "DASH": return # No interrumpir el dash

	# --- TAUNT LOCK ---
	if state == "TAUNT":
		if input_axis != 0: pass 
		else: return 

	# --- INPUT CHECKS ---
	
	# 1. ATTACK
	if Input.is_action_just_pressed("attack"):
		SetState("ATTACK")
		return

	# 2. DASH (NUEVO!)
	if Input.is_action_just_pressed("dash") and canDash:
		StartDash()
		return

	# --- MAIN MOVEMENT LOGIC ---
	var new_state = state

	if not is_on_floor():
		if velocity.y < 0:
			new_state = "JUMP"
		else:
			new_state = "FALLING"
	else:
		if state == "FALLING": 
			if input_axis == 0: new_state = "LAND" 
			else: new_state = "RUN"
		elif input_axis != 0 and abs(velocity.x) > 5.0:
			new_state = "RUN"
		else:
			if state == "RUN": new_state = "TAUNT" 
			elif state != "LAND" and state != "TAUNT": new_state = "IDLE"

	if new_state != state:
		SetState(new_state)

func SetState(new_state : String) -> void:
	state = new_state
	updateAnimation = true

func UpdateAnimation() -> void:
	updateAnimation = false
	# Asegúrate de tener una animación llamada "DASH" en tu AnimationPlayer
	if animation_player.has_animation(state):
		animation_player.play(state)
	else:
		# Fallback por si no tienes la animación hecha aún
		print("Falta animación: ", state) 

func TakeDamage():
	SetState("HURT")
	health -= 1
	signal_healthChanged.emit(health) 

func isAlive():
	return health > 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "LAND" or anim_name == "TAUNT" or anim_name == "ATTACK" or anim_name == "HURT":
		SetState("IDLE")
		
	if anim_name == "DEATH":
		playerSprite.visible = false
		SetState("IDLE")
		await Fade.fade_to_black(0.25)
		get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
