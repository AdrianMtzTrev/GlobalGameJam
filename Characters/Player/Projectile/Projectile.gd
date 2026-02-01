extends Node2D

const SPEED : int = 300

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# --- CONECTA ESTA SEÑAL: "area_entered" ---
# Esta función se encarga de MATAR AL ENEMIGO
func _on_area_2d_area_entered(area):
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("TakeDamage"):
			enemy.TakeDamage(1)
			queue_free() # Borra la bala

# --- CONECTA ESTA SEÑAL: "body_entered" ---
# Esta función se encarga de CHOCAR CON PAREDES
func _on_area_2d_body_entered(body):
	# Si choca con el mapa (Foreground) o cualquier objeto sólido
	print("Choque con pared: ", body.name)
	queue_free() # Borra la bala
