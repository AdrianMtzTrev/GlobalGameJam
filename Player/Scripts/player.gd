class_name Player extends CharacterBody2D

var cardinalDirection : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var moveSpeed : float = 100.0
var state = "IDLE"

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = direction * moveSpeed
	if SetState():
		UpdateAnimation()
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()


func SetDirection() -> bool:
	return true

func SetState() -> bool:
	var new_state = "IDLE" if direction == Vector2.ZERO else "WALKING" 
	return new_state == state

func UpdateAnimation() -> void:
	animation_player.play(state)
	return

func GetAnimation() -> String:
	
	return ""

func AnimationDirection() -> String:
	match cardinalDirection:
		Vector2.RIGHT:
			return "RIGHT"
		Vector2.LEFT:
			return "LEFT"
		Vector2.UP:
			return "UP"	
		Vector2.DOWN:
			return "DOWN"	
	
	return "NULL"
