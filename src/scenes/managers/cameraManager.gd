extends Node

@onready var player: Player = Utils.get_player()
@export var mainCamera: PackedScene

var currentCamera: MainCamera
var previousCamera: MainCamera

var screenShakeEnabled: bool = false

func _ready() -> void:
	load_camera_settings()

func load_camera_settings() -> void:
	if SaveManager.get_config_data("settings_special", "screen_shake") != null:
		screenShakeEnabled = SaveManager.get_config_data("settings_special", "screen_shake")

func set_current_camera(camera: MainCamera) -> void:
	if currentCamera != null && currentCamera.enabled:
		currentCamera.enabled = false
	
	currentCamera = camera
	
	if !currentCamera.enabled:
		currentCamera.enabled = true

func set_active_camera_bounds(bounds: Rect2, camera: MainCamera = currentCamera) -> void:
	print("updating camera bounds")
	print(bounds)
	if camera:
		camera.limit_left = bounds.position.x
		camera.limit_top = bounds.position.y
		camera.limit_right = bounds.position.x + bounds.size.x
		camera.limit_bottom = bounds.position.y + bounds.size.y
	else:
		Utils.debug_print(self, "no active camera provided, active camera instance '%s'", [camera])

func get_main_camera_instance() -> MainCamera:
	var camera: MainCamera = mainCamera.instantiate()
	return camera
