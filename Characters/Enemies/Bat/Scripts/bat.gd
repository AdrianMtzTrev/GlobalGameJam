extends CharacterBody2D

enum State {
	IDLE,
	FOLLOW,
	ATTACK
}

var state: State = State.IDLE

# --- VARIABLES DE CONFIGURACIÓN ---
@export var max_health : int = 2 # <--- NUEVO: Aguanta 2 golpes (puedes cambiarlo a 1)
@export var float_amplitude := 8.0
@export var float_speed := 2.0
@export var follow_speed := 60.0
@export var attack_speed := 180.0
@export var attack_range := 20.0
@export var attack_duration := 0.25

# --- VARIABLES INTERNAS ---
var current_health : int # <--- NUEVO: Para llevar la cuenta de la vida actual
var attack_dir := Vector2.ZERO
var attack_timer := 0.0
var start_y: float
var time := 0.0
var player: Node2D = null

@onready var sprite: Sprite2D = $BatSprite

func _ready():
	start_y = global_position.y
	
	# --- NUEVO: CONFIGURACIÓN INICIAL ---
	current_health = max_health
	add_to_group("Enemie") # <--- IMPORTANTE: Esto arregla el error del proyectil automáticamente

func _physics_process(delta):
	match state:
		State.IDLE:
			idle_float(delta)
		State.FOLLOW:
			follow_player(delta)
		State.ATTACK:
			attack(delta)

# --- SISTEMA DE DAÑO (NUEVO) ---

func TakeDamage(amount: int): # <--- Esta es la función que llama tu proyectil
	current_health -= amount
	
	# Efecto visual: Se pone rojo un momento al recibir el golpe
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		Die()

func Die():
	# Aquí podrías poner una animación de muerte o sonido
	queue_free() # Desaparece del juego

# --- MOVIMIENTO Y LÓGICA EXISTENTE ---

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
	if body.name == "Player" or body.is_in_group("Player"): # Mejoramos la detección un poco
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
	if body is Player: 
		if body.has_method("TakeDamage"):
			body.TakeDamage()
