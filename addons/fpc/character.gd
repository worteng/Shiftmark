# COPYRIGHT Colormatic Studios
# MIT license
# Quality Godot First Person Controller v2
extends CharacterBody3D
@export_group("Sounds")
@onready var footstep_sound: AudioStreamPlayer3D = $FootstepSound
#region Character Export Group
@export_category("Character")
@export var base_speed : float = 3.0
@export var sprint_speed : float = 6.0
@export var crouch_speed : float = 1.0
@export var acceleration : float = 10.0
@export var jump_velocity : float = 4.5
@export var mouse_sensitivity : float = 0.1
@export var invert_camera_x_axis : bool = false
@export var invert_camera_y_axis : bool = false
@export var immobile : bool = false
@export_file var default_reticle
#endregion
#region Nodes Export Group
@export_group("Nodes")
@export var HEAD : Node3D
@export var CAMERA : Camera3D
@export var HEADBOB_ANIMATION : AnimationPlayer
@export var JUMP_ANIMATION : AnimationPlayer
@export var CROUCH_ANIMATION : AnimationPlayer
@export var COLLISION_MESH : CollisionShape3D
#endregion
#region Controls Export Group
@export_group("Controls")
@export var controls : Dictionary = {
	LEFT = "ui_left",
	RIGHT = "ui_right",
	FORWARD = "ui_up",
	BACKWARD = "ui_down",
	JUMP = "ui_accept",
	CROUCH = "crouch",
	SPRINT = "sprint",
	PAUSE = "ui_cancel"
	}
@export_subgroup("Controller Specific")
@export var controller_support : bool = false
@export var controller_controls : Dictionary = {
	LOOK_LEFT = "look_left",
	LOOK_RIGHT = "look_right",
	LOOK_UP = "look_up",
	LOOK_DOWN = "look_down"
	}
@export_range(0.001, 1, 0.001) var look_sensitivity : float = 0.035
#endregion
#region Feature Settings Export Group
@export_group("Feature Settings")
@export var jumping_enabled : bool = true
@export var in_air_momentum : bool = true
@export var motion_smoothing : bool = true
@export var sprint_enabled : bool = true
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
@export var crouch_enabled : bool = true
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
@export var dynamic_fov : bool = true
@export var continuous_jumping : bool = true
@export var view_bobbing : bool = true
@export var jump_animation : bool = true
@export var pausing_enabled : bool = true
@export var gravity_enabled : bool = true
@export var dynamic_gravity : bool = false
#endregion
#region Member Variable Initialization
var speed : float = base_speed
var current_speed : float = 0.0
var state : String = "normal"
var low_ceiling : bool = false
var was_on_floor : bool = true
var RETICLE : Control
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouseInput : Vector2 = Vector2(0,0)
#endregion
#region Main Control Flow
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	if default_reticle:
		change_reticle(default_reticle)
	initialize_animations()
	check_controls()
	enter_normal_state()
func _process(_delta):
	if Input.get_connected_joypads().size() > 0:
		var stick_x = Input.get_joy_axis(0, 2)
		var stick_y = Input.get_joy_axis(0, 3)
		print("Stick X: $stick_x, Y: $stick_y")
	else:
		print("Контроллер не подключен")
	if pausing_enabled:
		handle_pausing()
	update_debug_menu_per_frame()
func _physics_process(delta):
	if dynamic_gravity:
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if not is_on_floor() and gravity and gravity_enabled:
		velocity.y -= gravity * delta
	handle_jumping()
	var input_dir = Vector2.ZERO
	if not immobile:
		input_dir = Input.get_vector(controls.LEFT, controls.RIGHT, controls.FORWARD, controls.BACKWARD)
	handle_movement(delta, input_dir)
	handle_head_rotation()
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	handle_state(input_dir)
	if dynamic_fov:
		update_camera_fov()
	if view_bobbing:
		play_headbob_animation(input_dir)
	var is_moving := is_on_floor() and input_dir != Vector2.ZERO
	if is_moving and state in ["normal", "sprinting", "crouching"]:
		if not footstep_sound.playing:
			footstep_sound.play()
	else:
		if footstep_sound.playing:
			footstep_sound.stop()
	if footstep_sound.playing:
		match state:
			"crouching":
				footstep_sound.pitch_scale = 0.5
			"sprinting":
				footstep_sound.pitch_scale = 2.0
			_:
				footstep_sound.pitch_scale = 1.0
	if jump_animation:
		play_jump_animation()
	update_debug_menu_per_tick()
	was_on_floor = is_on_floor()
#endregion
#region Input Handling
func handle_jumping():
	if jumping_enabled:
		if continuous_jumping:
			if Input.is_action_pressed(controls.JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity
		else:
			if Input.is_action_just_pressed(controls.JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity
func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	move_and_slide()
	if in_air_momentum:
		if is_on_floor():
			if motion_smoothing:
				velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
			else:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
	else:
		if motion_smoothing:
			velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
func handle_head_rotation():
	# Обработка мыши
	if invert_camera_x_axis:
		HEAD.rotation_degrees.y -= mouseInput.x * mouse_sensitivity * -1
	else:
		HEAD.rotation_degrees.y -= mouseInput.x * mouse_sensitivity

	if invert_camera_y_axis:
		HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity * -1
	else:
		HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity

	# Обработка правого стика через InputMap
	if controller_support:
		var x_axis := 0.0
		var y_axis := 0.0
		
		if Input.is_action_pressed(controller_controls.LOOK_RIGHT):
			x_axis += 1
		if Input.is_action_pressed(controller_controls.LOOK_LEFT):
			x_axis -= 1
		if Input.is_action_pressed(controller_controls.LOOK_UP):
			y_axis += 1
		if Input.is_action_pressed(controller_controls.LOOK_DOWN):
			y_axis -= 1

		if invert_camera_x_axis:
			x_axis *= -1
		if invert_camera_y_axis:
			y_axis *= -1

		HEAD.rotation.y += x_axis * look_sensitivity
		HEAD.rotation.x += y_axis * look_sensitivity

	# Сброс мыши
	mouseInput = Vector2.ZERO

	# Ограничение обзора по вертикали
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func check_controls():
	if !InputMap.has_action(controls.JUMP):
		push_error("No control mapped for jumping. Please add an input map control. Disabling jump.")
		jumping_enabled = false
	if !InputMap.has_action(controls.LEFT):
		push_error("No control mapped for move left. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.RIGHT):
		push_error("No control mapped for move right. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.FORWARD):
		push_error("No control mapped for move forward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.BACKWARD):
		push_error("No control mapped for move backward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.PAUSE):
		push_error("No control mapped for pause. Please add an input map control. Disabling pausing.")
		pausing_enabled = false
	if !InputMap.has_action(controls.CROUCH):
		push_error("No control mapped for crouch. Please add an input map control. Disabling crouching.")
		crouch_enabled = false
	if !InputMap.has_action(controls.SPRINT):
		push_error("No control mapped for sprint. Please add an input map control. Disabling sprinting.")
		sprint_enabled = false
#endregion
#region State Handling
func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(controls.SPRINT) and state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				if Input.is_action_pressed(controls.SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(controls.SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(controls.CROUCH) and state != "sprinting":
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(controls.CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()
func enter_normal_state():
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed
func enter_crouch_state():
	state = "crouching"
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")
func enter_sprint_state():
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed
#endregion
#region Animation Handling
func initialize_animations():
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")
func play_headbob_animation(moving):
	if moving and is_on_floor():
		var use_headbob_animation : String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"
		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true
		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2))
	else:
		if HEADBOB_ANIMATION.current_animation == "sprint" or HEADBOB_ANIMATION.current_animation == "walk":
			HEADBOB_ANIMATION.speed_scale = 1
			HEADBOB_ANIMATION.play("RESET", 1)
func play_jump_animation():
	if !was_on_floor and is_on_floor():
		var facing_direction : Vector3 = CAMERA.get_global_transform().basis.x
		var facing_direction_2D : Vector2 = Vector2(facing_direction.x, facing_direction.z).normalized()
		var velocity_2D : Vector2 = Vector2(velocity.x, velocity.z).normalized()
		var side_landed : int = round(velocity_2D.dot(facing_direction_2D))
		if side_landed > 0:
			JUMP_ANIMATION.play("land_right", 0.25)
		elif side_landed < 0:
			JUMP_ANIMATION.play("land_left", 0.25)
		else:
			JUMP_ANIMATION.play("land_center", 0.25)
#endregion
#region Debug Menu
func update_debug_menu_per_frame():
	$UserInterface/DebugPanel.add_property("FPS", Performance.get_monitor(Performance.TIME_FPS), 0)
	var status : String = state
	if !is_on_floor():
		status += " in the air"
	$UserInterface/DebugPanel.add_property("State", status, 4)
	if controller_support:
		var look_left_active = Input.is_action_pressed(controller_controls.LOOK_LEFT)
		var look_right_active = Input.is_action_pressed(controller_controls.LOOK_RIGHT)
		var look_up_active = Input.is_action_pressed(controller_controls.LOOK_UP)
		var look_down_active = Input.is_action_pressed(controller_controls.LOOK_DOWN)
		$UserInterface/DebugPanel.add_property("Controller Active", "Yes", 5)
		$UserInterface/DebugPanel.add_property("Look Left", str(look_left_active), 6)
		$UserInterface/DebugPanel.add_property("Look Right", str(look_right_active), 7)
		$UserInterface/DebugPanel.add_property("Look Up", str(look_up_active), 8)
		$UserInterface/DebugPanel.add_property("Look Down", str(look_down_active), 9)
	else:
		$UserInterface/DebugPanel.add_property("Controller Active", "No", 5)
func update_debug_menu_per_tick():
	current_speed = Vector3.ZERO.distance_to(get_real_velocity())
	$UserInterface/DebugPanel.add_property("Speed", snappedf(current_speed, 0.001), 1)
	$UserInterface/DebugPanel.add_property("Target speed", speed, 2)
	var cv : Vector3 = get_real_velocity()
	var vd : Array[float] = [
		snappedf(cv.x, 0.001),
		snappedf(cv.y, 0.001),
		snappedf(cv.z, 0.001)
	]
	var readable_velocity : String = "X: " + str(vd[0]) + " Y: " + str(vd[1]) + " Z: " + str(vd[2])
	$UserInterface/DebugPanel.add_property("Velocity", readable_velocity, 3)
func _unhandled_input(event : InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y
	elif event is InputEventKey:
		if event.is_released():
			if event.keycode == 4194338:
				$UserInterface/DebugPanel.visible = !$UserInterface/DebugPanel.visible
#endregion
#region Misc Functions
func change_reticle(reticle):
	if RETICLE:
		RETICLE.queue_free()
	RETICLE = load(reticle).instantiate()
	RETICLE.character = self
	$UserInterface.add_child(RETICLE)
func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)
func handle_pausing():
	if Input.is_action_just_pressed(controls.PAUSE):
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#endregion
