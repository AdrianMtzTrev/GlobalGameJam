extends CharacterBody2D

enum State {
	IDLE,
	FOLLOW,
	ATTACK
}

var state: State = State.IDLE

@export var float_amplitude := 8.0
@export var float_speed := 2.0
@export var follow_speed := 60.0
@export var attack_speed := 180.0
@export var attack_range := 20.0
@export var attack_duration := 0.25

var attack_dir := Vector2.ZERO
var attack_timer := 0.0

var start_y: float
var time := 0.0
var player: Node2D = null

@onready var sprite: Sprite2D = $BatSprite


func _ready():
	start_y = global_position.y


func _physics_process(delta):
	match state:
		State.IDLE:
			idle_float(delta)
		State.FOLLOW:
			follow_player(delta)
		State.ATTACK:
			attack(delta)


func idle_float(delta):
	time += delta * float_speed
	global_position.y = start_y + sin(time) * float_amplitude
	velocity = Vector2.ZERO


func follow_player(delta):
	if player == null:
		state = State.IDLE
		start_y = global_position.y
		return

	var to_player = player.global_position - global_position
	var dir = to_player.normalized()

	# Voltear sprite
	sprite.flip_h = dir.x > 0

	# ¿Está a rango de ataque?
	if to_player.length() <= attack_range:
		start_attack(dir)
		return

	# Seguir al jugador
	velocity = dir * follow_speed
	move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
		if body.name == "Player":
			player = body
			state = State.FOLLOW

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		state = State.IDLE
		start_y = global_position.y
		
func start_attack(dir: Vector2):
	state = State.ATTACK
	attack_dir = dir
	attack_timer = attack_duration
	
func attack(delta):
	attack_timer -= delta

	if attack_timer <= 0:
		state = State.FOLLOW
		return

	velocity = attack_dir * attack_speed
	move_and_slide()


func _on_attack_area_body_entered(body: Node2D) -> void:
	# Verificamos si lo que tocamos es el Jugador
	if body is Player: # Gracias a que pusiste "class_name Player" en tu script
		# Verificamos que el jugador tenga la función de recibir daño
		if body.has_method("TakeDamage"):
			body.TakeDamage() 
			# Opcional: Empujar al jugador (Knockback) si quisieras
