extends Node



var activeCamera: Camera2D
var previousCamera: Camera2D

var screenShakeEnabled: bool = false

func _ready() -> void:
	pass 


func set_camera_active(camera: Camera2D, active: bool) -> void:
	previousCamera = activeCamera
	var newActiveCamera: Camera2D = camera
	
	previousCamera.enabled = false
	
	activeCamera = newActiveCamera
	newActiveCamera.enabled = active
	
	if active == false:
		previousCamera.enabled = true
		activeCamera = previousCamera
