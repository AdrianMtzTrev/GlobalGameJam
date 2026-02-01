extends Node2D

const SPEED : int = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.x * SPEED * delta
	return


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	return
