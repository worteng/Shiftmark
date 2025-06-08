extends AudioStreamPlayer3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 5, 0)

func _process(delta):
	if target:
		position = target.position + offset
