extends Control

@export var player_path: NodePath
@onready var player = get_node(player_path)
@onready var map_image = $Map  # Укажи путь к твоему TextureRect
@export var world_size = Vector2(1000, 1000)  # Размер игрового мира
@export var map_center = Vector2(-650, 300)    # Центр карты
@export var minimap_speed = 1.0               # Скорость перемещения карты

func _process(_delta):
	if not player:
		return

	var world_pos = Vector2(player.global_position.x, player.global_position.z)
	var half_world = world_size * 0.5
	var map_origin = map_center - half_world
	var relative_pos = (world_pos - map_origin) / world_size
	var map_size = map_image.get_rect().size
	var map_offset = Vector2(1 - relative_pos.x, relative_pos.y) * map_size * minimap_speed

	map_image.position = map_offset
