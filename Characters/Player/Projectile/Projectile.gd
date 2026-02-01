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

func _on_area_entered(area):
	# Si el área que tocamos se llama "Hurtbox", es el punto débil del Boss
	if area.name == "Hurtbox":
		# Buscamos al padre del Hurtbox (que es el Boss) y le hacemos daño
		var boss = area.get_parent()
		if boss.has_method("TakeDamage"):
			boss.TakeDamage(1)
			queue_free() # El proyectil desaparece al impactar


func _on_attack_area_body_entered(body: Node2D) -> void:
	# Verificamos si lo que tocamos es el Jugador
	if body is Enemie: # Gracias a que pusiste "class_name Player" en tu script
		# Verificamos que el jugador tenga la función de recibir daño
		if body.has_method("TakeDamage"):
			body.TakeDamage() 
			# Opcional: Empujar al jugador (Knockback) si quisieras
