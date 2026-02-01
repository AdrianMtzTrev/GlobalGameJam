extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var max_health : int = 10
@export var speed : float = 80.0
@export var detection_range : float = 200.0
@export var attack_range : float = 40.0

# --- REFERENCIAS ---
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
var player_ref : Player = null # Referencia al jugador para saber dónde está

# --- VARIABLES INTERNAS ---
var health : int = max_health
var state : String = "IDLE" # IDLE, CHASE, ATTACK, HURT, DEATH
var gravity : float = 980.0

func _ready() -> void:
	# Buscar al jugador automáticamente (Asegúrate de que tu Player tenga "class_name Player")
	# O agrégalo a un grupo llamado "Player"
	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_ref = players[0]

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Máquina de Estados (La "Cerebro" del Boss)
	match state:
		"IDLE":
			velocity.x = 0
			_check_for_player()
			
		"CHASE":
			if player_ref:
				_chase_player()
			else:
				state = "IDLE"
				
		"ATTACK":
			velocity.x = 0
			# Aquí esperamos a que termine la animación de ataque
			
		"HURT":
			velocity.x = 0
			
		"DEATH":
			velocity = Vector2.ZERO

	move_and_slide()

# --- LÓGICA DE COMPORTAMIENTO ---

func _check_for_player():
	animation_player.play("IDLE")
	if player_ref:
		var distance = global_position.distance_to(player_ref.global_position)
		if distance < detection_range:
			state = "CHASE"

func _chase_player():
	animation_player.play("RUN")
	var direction = (player_ref.global_position - global_position).normalized()
	
	# Voltear sprite hacia el jugador
	if direction.x > 0: sprite.flip_h = true # Derecha
	else: sprite.flip_h = false # Izquierda
	
	velocity.x = direction.x * speed
	
	# Si estamos cerca, ATACAR
	if global_position.distance_to(player_ref.global_position) < attack_range:
		state = "ATTACK"
		animation_player.play("ATTACK")

# --- SISTEMA DE DAÑO (Igual que el Player) ---

func TakeDamage(amount: int):
	if state == "DEATH": return
	
	health -= amount
	print("Boss Health: ", health)
	
	if health <= 0:
		Die()
	else:
		state = "HURT"
		animation_player.play("HURT")

func Die():
	state = "DEATH"
	animation_player.play("DEATH")
	# Opcional: Desactivar colisiones
	$CollisionShape2D.set_deferred("disabled", true)

# --- SEÑALES ---

# Conecta la señal "animation_finished" del AnimationPlayer del Boss aquí
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "ATTACK":
		state = "IDLE" # Vuelve a pensar qué hacer después de atacar
		
	if anim_name == "HURT":
		state = "IDLE" # Se recuperó del golpe
		
	if anim_name == "DEATH":
		queue_free() # Desaparecer al Boss
