extends Control

const CONFIG_PATH := "user://rendering_settings.cfg"

# GUI элементы (должны быть в сцене с указанными именами)
@onready var option_bvh_quality: OptionButton = $VBoxContainer/OptionBVHQuality
@onready var spin_occlusion_rays: SpinBox = $VBoxContainer/SpinOcclusionRays
@onready var check_nearest_mipmap: CheckBox = $VBoxContainer/CheckNearestMipmap
@onready var slider_aniso_level: HSlider = $VBoxContainer/SliderAnisoLevel
@onready var slider_mipmap_bias: HSlider = $VBoxContainer/SliderMipmapBias
@onready var option_rendering_method: OptionButton = $VBoxContainer/OptionRenderingMethod
@onready var spin_msaa_3d: SpinBox = $VBoxContainer/SpinMSAA3D
@onready var check_taa: CheckBox = $VBoxContainer/CheckTAA
@onready var option_scale_mode: OptionButton = $VBoxContainer/OptionScaleMode
@onready var slider_scale: HSlider = $VBoxContainer/SliderScale

func _ready():
	# Устанавливаем шаги для удобства взаимодействия
	spin_occlusion_rays.step = 4
	spin_occlusion_rays.min_value = 4
	spin_occlusion_rays.max_value = 256

	slider_aniso_level.step = 1
	slider_aniso_level.min_value = 1
	slider_aniso_level.max_value = 16

	slider_mipmap_bias.step = 0.01
	slider_mipmap_bias.min_value = -1.0
	slider_mipmap_bias.max_value = 1.0

	spin_msaa_3d.step = 2
	spin_msaa_3d.min_value = 0
	spin_msaa_3d.max_value = 8

	slider_scale.step = 0.01
	slider_scale.min_value = 0.1
	slider_scale.max_value = 2.0

func apply_settings():
	ProjectSettings.set_setting("rendering/occlusion_culling/bvh_build_quality", option_bvh_quality.get_item_text(option_bvh_quality.selected))
	ProjectSettings.set_setting("rendering/occlusion_culling/occlusion_rays_per_thread", spin_occlusion_rays.value)
	ProjectSettings.set_setting("rendering/textures/default_filters/use_nearest_mipmap_filter", check_nearest_mipmap.button_pressed)
	ProjectSettings.set_setting("rendering/textures/default_filters/anisotropic_filtering_level", slider_aniso_level.value)
	ProjectSettings.set_setting("rendering/textures/default_filters/texture_mipmap_bias", slider_mipmap_bias.value)
	ProjectSettings.set_setting("rendering/renderer/rendering_method", option_rendering_method.get_item_text(option_rendering_method.selected))
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/msaa_3d", spin_msaa_3d.value)
	ProjectSettings.set_setting("rendering/anti_aliasing/quality/use_taa", check_taa.button_pressed)
	ProjectSettings.set_setting("rendering/scaling_3d/mode", option_scale_mode.get_item_text(option_scale_mode.selected))
	ProjectSettings.set_setting("rendering/scaling_3d/scale", slider_scale.value)

	ProjectSettings.save()
	print("[Rendering Settings] Applied")

func save_settings():
	print("[Rendering Settings] Saving with parameters:")
	print("  BVH Quality:", option_bvh_quality.selected)
	print("  Occlusion Rays:", spin_occlusion_rays.value)
	print("  Nearest Mipmap:", check_nearest_mipmap.button_pressed)
	print("  Aniso Level:", slider_aniso_level.value)
	print("  Mipmap Bias:", slider_mipmap_bias.value)
	print("  Rendering Method:", option_rendering_method.selected)
	print("  MSAA 3D:", spin_msaa_3d.value)
	print("  TAA:", check_taa.button_pressed)
	print("  Scale Mode:", option_scale_mode.selected)
	print("  Scale:", slider_scale.value)
	var config = ConfigFile.new()
	config.set_value("rendering", "bvh_build_quality", option_bvh_quality.selected)
	config.set_value("rendering", "occlusion_rays", spin_occlusion_rays.value)
	config.set_value("rendering", "nearest_mipmap", check_nearest_mipmap.button_pressed)
	config.set_value("rendering", "aniso", slider_aniso_level.value)
	config.set_value("rendering", "mipmap_bias", slider_mipmap_bias.value)
	config.set_value("rendering", "method", option_rendering_method.selected)
	config.set_value("rendering", "msaa_3d", spin_msaa_3d.value)
	config.set_value("rendering", "taa", check_taa.button_pressed)
	config.set_value("rendering", "scale_mode", option_scale_mode.selected)
	config.set_value("rendering", "scale", slider_scale.value)
	config.save(CONFIG_PATH)
	print("[Rendering Settings] Saved to config")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("[Rendering Settings] No config found")
		return

	var bvh_index = config.get_value("rendering", "bvh_build_quality", 1)
	if bvh_index >= 0 and bvh_index < option_bvh_quality.item_count:
		option_bvh_quality.select(bvh_index)

	spin_occlusion_rays.value = config.get_value("rendering", "occlusion_rays", 32)
	check_nearest_mipmap.button_pressed = config.get_value("rendering", "nearest_mipmap", false)
	slider_aniso_level.value = config.get_value("rendering", "aniso", 4)
	slider_mipmap_bias.value = config.get_value("rendering", "mipmap_bias", 0.0)

	var method_index = config.get_value("rendering", "method", 0)
	if method_index >= 0 and method_index < option_rendering_method.item_count:
		option_rendering_method.select(method_index)

	spin_msaa_3d.value = config.get_value("rendering", "msaa_3d", 4)
	check_taa.button_pressed = config.get_value("rendering", "taa", true)

	var scale_mode_index = config.get_value("rendering", "scale_mode", 0)
	if scale_mode_index >= 0 and scale_mode_index < option_scale_mode.item_count:
		option_scale_mode.select(scale_mode_index)

	slider_scale.value = config.get_value("rendering", "scale", 0.85)

	print("[Rendering Settings] Loaded from config")
