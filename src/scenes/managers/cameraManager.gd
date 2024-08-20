extends Node

@onready var player: Player = Utils.get_player()
@export var mainCamera: PackedScene

var activeCamera: Camera2D
var previousCamera: Camera2D

var screenShakeEnabled: bool = false

func _ready() -> void:
	load_camera_settings()

func load_camera_settings() -> void:
	if SaveManager.get_config_data("settings_special", "screen_shake") != null:
		screenShakeEnabled = SaveManager.get_config_data("settings_special", "screen_shake")

func set_camera_active(camera: Camera2D, active: bool) -> void:
	previousCamera = activeCamera
	var newActiveCamera: Camera2D = camera
	
	previousCamera.enabled = false
	
	activeCamera = newActiveCamera
	newActiveCamera.enabled = active
	
	if active == false:
		previousCamera.enabled = true
		activeCamera = previousCamera

func set_active_camera_bounds(bounds: Dictionary) -> void:#_left, _right, _bot, _top) -> void:
	var leftLimit: int = bounds["left"]
	var rightLimit: int = bounds["right"]
	var topLimit: int = bounds["top"]
	var bottomLimit: int = bounds["bottom"]
	print(bounds)

func get_player_camera_instance() -> Camera2D:
	var camera: Camera2D = mainCamera.instantiate()
	return camera
