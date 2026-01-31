class_name Player extends CharacterBody2D

var cardinalDirection : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var moveSpeed : float = 100.0
var state : String = "IDLE"
var updateAnimation : bool = true

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
	if updateAnimation:
		UpdateAnimation()
	UpdateState()
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()


func SetDirection() -> bool:
	return true

func UpdateState() -> void:
	match direction:
		Vector2.ZERO:
			updateAnimation = state != "IDLE"
			SetState("IDLE")
			return
		Vector2.UP:
			updateAnimation = state != "WALK_UP"
			SetState("WALK_UP")
			return
		Vector2.DOWN:
			updateAnimation = state != "WALK_DOWN"
			SetState("WALK_DOWN")
			return
		Vector2.LEFT:
			updateAnimation = state != "WALK_LEFT"
			SetState("WALK_LEFT")
			return
		Vector2.RIGHT:
			updateAnimation = state != "WALK_RIGHT"
			SetState("WALK_RIGHT")
			return
	return

func SetState(new_state : String) -> void:
	state = new_state
	return

func UpdateAnimation() -> void:
	updateAnimation = false
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
