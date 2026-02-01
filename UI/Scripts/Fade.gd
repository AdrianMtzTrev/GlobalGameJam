extends CanvasLayer

@onready var rect := ColorRect.new()

func _ready():
	rect.color = Color.BLACK
	rect.size = get_viewport().size
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	
func fade_to_black(duration := 1.0) -> void:
	rect.visible = true
	rect.modulate.a = 0.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	await tween.finished
	
func fade_from_black(duration := 1.0) -> void:
	rect.modulate.a = 1.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	await tween.finished
	
	rect.visible = false
