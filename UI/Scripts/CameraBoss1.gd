extends Area2D

@export var Boss_camera: Camera2D

func _on_body_entered(body):
	if body.name == "Player":
		Boss_camera.make_current()
