extends Control

func _on_button_start_pressed():
	print("Загрузка началась...")

	var scene_path = "res://menu.tscn"
	var packed_scene = ResourceLoader.load(scene_path)

	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
		print("Загрузка завершена!")
	else:
		push_error("Не удалось загрузить сцену: %s" % scene_path)
