# SettingsGUI.gd — Подключи к сцене с элементами интерфейса в Godot 4.3
# В сцене должны быть соответствующие Control-элементы с нужными именами.

extends Control

const CONFIG_PATH := "res://rendering_settings.cfg"

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

	option_bvh_quality.select(config.get_value("rendering", "bvh_build_quality", 1))
	spin_occlusion_rays.value = config.get_value("rendering", "occlusion_rays", 32)
	check_nearest_mipmap.button_pressed = config.get_value("rendering", "nearest_mipmap", false)
	slider_aniso_level.value = config.get_value("rendering", "aniso", 4)
	slider_mipmap_bias.value = config.get_value("rendering", "mipmap_bias", 0.0)
	option_rendering_method.select(config.get_value("rendering", "method", 0))
	spin_msaa_3d.value = config.get_value("rendering", "msaa_3d", 4)
	check_taa.button_pressed = config.get_value("rendering", "taa", true)
	option_scale_mode.select(config.get_value("rendering", "scale_mode", 0))
	slider_scale.value = config.get_value("rendering", "scale", 0.85)
	print("[Rendering Settings] Loaded from config")
