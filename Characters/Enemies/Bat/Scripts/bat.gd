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

var start_y: float
var time := 0.0
var player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	start_y = global_position.y


func _physics_process(delta):
	match state:
		State.IDLE:
			idle_float(delta)
		State.FOLLOW:
			follow_player(delta)
		State.ATTACK:
			pass


func idle_float(delta):
	time += delta * float_speed
	global_position.y = start_y + sin(time) * float_amplitude
	velocity = Vector2.ZERO


func follow_player(delta):
	if player == null:
		state = State.IDLE
		start_y = global_position.y
		return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * follow_speed

	# Voltear sprite según dirección
	sprite.flip_h = dir.x > 0

	move_and_slide()
