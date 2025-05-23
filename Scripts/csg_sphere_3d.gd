# Spawner.gd - скрипт для CSGSphere3D спавнера
extends CSGSphere3D

@export var ball_scene: PackedScene
@export var spawn_count: int = 10

func _ready():
	for i in range(spawn_count):
		var ball = ball_scene.instantiate()
		add_child(ball)
		ball.global_position = global_position + Vector3(0, i * 2, 0) # Распределяем по высоте
