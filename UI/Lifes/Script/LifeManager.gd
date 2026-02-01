extends Node2D

# CONSTANTS
const HEART_SCALE: Vector2 = Vector2(0.1, 0.1)

# Reference variables for texture & player
@export var heart_texture: Texture2D 
@export var player_ref : Player 

@export var distance_between_hearts: float = 50.0 

func _ready():
	# Safety Check: Is the player assigned in the Inspector?
	if player_ref != null:
		# Get the max health directly from the Player's constant
		var max_hearts = player_ref.HEARTS_MASKS
		
		# Create the visuals
		create_hearts(max_hearts)
		
		# This saves you from having to click "Connect" in the Node tab
		if not player_ref.signal_healthChanged.is_connected(_on_player_health_changed):
			player_ref.signal_healthChanged.connect(_on_player_health_changed)
	else:
		print("ERROR: Please assign the Player node to the HealthContainer in the Inspector!")

func create_hearts(amount: int):
	# Clear old hearts
	for child in get_children():
		child.queue_free()
	
	# Generate new hearts
	for i in range(amount):
		var heart = Sprite2D.new()
		heart.texture = heart_texture
		heart.hframes = 2
		heart.frame = 0 # Full
		heart.scale = HEART_SCALE
		heart.position = Vector2((i * distance_between_hearts) + 30, 20)
		add_child(heart)

func _on_player_health_changed(current_health: int):
	var hearts = get_children()
	for i in range(hearts.size()):
		if i < current_health:
			hearts[i].frame = 0 # Full
		else:
			hearts[i].frame = 1 # Broken
