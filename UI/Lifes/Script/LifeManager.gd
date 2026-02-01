extends Node2D

const HEART_SCALE: Vector2 = Vector2(0.1, 0.1)

@export var heart_texture: Texture2D
@export var player_ref: Player
@export var distance_between_hearts: float = 50.0

func _ready():
	if player_ref:
		# 1. Create the hearts based on Player constants
		create_hearts(player_ref.HEARTS_MASKS)
		
		# 2. Connect the signal for future damage
		if not player_ref.signal_healthChanged.is_connected(_on_player_health_changed):
			player_ref.signal_healthChanged.connect(_on_player_health_changed)
			
		# 3. FORCE UPDATE NOW (This fixes the "Broken on Start" bug)
		# We manually run the update logic once so the UI matches the starting health (6)
		_on_player_health_changed(player_ref.health)

func create_hearts(amount: int):
	for child in get_children():
		child.queue_free()
	
	for i in range(amount):
		var heart = Sprite2D.new()
		heart.texture = heart_texture
		heart.hframes = 2
		heart.scale = HEART_SCALE 
		heart.position = Vector2((i * distance_between_hearts) + 30, 20)
		add_child(heart)

func _on_player_health_changed(current_health: int):
	var hearts = get_children()
	
	# We get the resistance value directly from the player script (e.g., 2)
	var resistance = player_ref.HEARTS_MASKS_RESITANCE
	
	for i in range(hearts.size()):
		# Dynamic Math: Heart 1 is max 2, Heart 2 is max 4, etc.
		var heart_max_value = (i + 1) * resistance
		
		if current_health >= heart_max_value:
			# Case 1: Full Heart (Health is 6, max is 6)
			hearts[i].frame = 0 
			hearts[i].visible = true
			
		elif current_health > (heart_max_value - resistance):
			# Case 2: Broken Heart (Health is 5, max is 6)
			# This logic works for any resistance value (even if you change it to 3 later)
			hearts[i].frame = 1 
			hearts[i].visible = true
			
		else:
			# Case 3: Empty/Disappear
			hearts[i].visible = false
