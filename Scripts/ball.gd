# Ball.gd - скрипт для отдельного шара
extends RigidBody3D

@onready var mesh_instance = $MeshInstance3D
@export var color_list: Array = [Color(1,0,0), Color(0,1,0), Color(0,0,1)]

func _ready():
	add_to_group("balls")
	# Устанавливаем случайный цвет из списка
	var random_color = color_list.pick_random()
	var material = StandardMaterial3D.new()
	material.albedo_color = random_color
	mesh_instance.material_override = material
	
	# Применяем случайную силу для движения
	var direction = Vector3(randf_range(-1,1), randf_range(0,2), randf_range(-1,1)).normalized()
	apply_impulse(Vector3.ZERO, direction * 5)
