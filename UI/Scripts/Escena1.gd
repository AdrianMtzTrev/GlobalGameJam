extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Fade.fade_from_black(1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
