extends Area2D

@export var next_scene_path: String

func _on_body_entered(body: Node2D) -> void:
	if  body.name == "Player":
		body.set_physics_process(false) # opcional
		await Fade.fade_to_black(0.25)
		await get_tree().create_timer(1.0).timeout
		Game.spawn_point_name = "Entrada_Desde_Boss1"
		get_tree().change_scene_to_file("res://Scenes/escena_Boss1.tscn")
		
