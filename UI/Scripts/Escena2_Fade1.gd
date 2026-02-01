extends Node2D

@onready var player = $Player

func _ready():
	if Game.spawn_point_name != "":
		var marker = get_node_or_null(Game.spawn_point_name)
		if marker:
			player.global_position = marker.global_position
			Game.spawn_point_name = ""
	await Fade.fade_from_black(1.0)
