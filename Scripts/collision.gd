# PlayerController.gd
extends Area3D

@export var repulsion_force: float = 1.0 # Сила отталкивания


func _on_body_entered(body):
	print("Body detected:", body.name)  # Тест за детекција
	if body.is_in_group("balls"):
		var direction = (body.global_position - global_position).normalized()
		body.apply_impulse(Vector3.ZERO, direction * repulsion_force)
