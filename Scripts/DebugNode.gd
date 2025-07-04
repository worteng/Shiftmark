extends Node3D

@export var player_path: NodePath
var player: Node3D

func _ready():
	if player_path:
		player = get_node(player_path)
	print_debug_info()

func _process(_delta):
	debug_draw()

func print_debug_info():
	print("================== DEBUG INFO ==================")
	print("📁 Scene tree:")
	log_tree(get_tree().get_root(), 0)

	print("\n🌍 World Environment:")
	# ✅ Fixed: correct way to access the environment in Godot 4.3
	var world := get_viewport().get_world_3d()
	if world:
		var env := world.environment
		if env:
			print("Background mode:", env.background_mode)
			print("SSAO enabled:", env.ssao_enabled)
			print("SSIL enabled:", env.ssil_enabled)
			print("SDFGI enabled:", env.sdfgi_enabled)
		else:
			print("❌ No environment assigned.")
	else:
		print("❌ No World3D available.")

	print("\n💡 Lights in scene:")
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		print("- ", light.name, " type: ", typeof(light))

	print("\n🧍 Player node: ", player if player else "❌ Not assigned")
	print("===============================================")

func log_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + node.name + " [" + node.get_class() + "]")
	for child in node.get_children():
		log_tree(child, depth + 1)

func debug_draw():
	if player:
		var info := "PLAYER POS: " + str(player.global_position)
		info += "\nROT: " + str(player.global_rotation_degrees)
		DebugDraw.draw_text(info)
