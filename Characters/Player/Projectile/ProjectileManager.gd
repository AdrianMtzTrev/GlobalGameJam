extends Node2D

const BULLET = preload("res://Characters/Player/Projectile/projectile.tscn")
@onready var spawnPoint : Marker2D = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("attack"):
		var bullet_instance = BULLET.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = spawnPoint.global_position
		bullet_instance.global_rotation = spawnPoint.global_rotation
	return
