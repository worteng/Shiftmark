extends StaticBody3D

var health = 100.0  # Здоровье объекта

func _ready():
	var fps_hands = get_node("/root/World/Character/FpsHands")  # Укажите правильный путь
	fps_hands.give_damage.connect(_on_give_damage)

func _on_give_damage(obj: Node3D, damage: float, point: Vector3):
	if obj == self:
		health -= damage
		print("Объект получил урон: ", damage, " в точке: ", point)
		if health <= 0:
			queue_free()  # Удалить объект при нулевом здоровье
