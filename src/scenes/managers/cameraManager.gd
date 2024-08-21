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

func set_active_camera_bounds(bounds: Dictionary, camera: MainCamera = currentCamera) -> void:
	var leftLimit: int = bounds["left"]
	var rightLimit: int = bounds["right"]
	var topLimit: int = bounds["up"]
	var bottomLimit: int = bounds["down"]
	
	camera.limit_left = leftLimit
	camera.limit_right = rightLimit
	camera.limit_top = topLimit
	camera.limit_bottom = bottomLimit

func get_main_camera_instance() -> MainCamera:
	var camera: MainCamera = mainCamera.instantiate()
	return camera
