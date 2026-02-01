extends Area2D

@export var pasillo_camera: Camera2D
@export var player_camera: Camera2D

func _on_body_entered(body):
	if body.name == "Player":
		print("Entró al pasillo")
		pasillo_camera.make_current()

func _on_body_exited(body):
	if body.name == "Player":
		print("Salió del pasillo")
		player_camera.make_current()
