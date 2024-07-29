extends CanvasLayer

@export var pixelPerfectCamera: Camera2D

@onready var mainCamera: Camera2D = NodeUtility.get_main_camera()
@onready var subViewport = $SubViewport

func _ready() -> void:
	await get_tree().process_frame
	
	var pixelPerfectObjects: Array = get_tree().get_nodes_in_group("pp")
	for i in pixelPerfectObjects:
		i.call_deferred("reparent", subViewport, true)

func _process(delta: float) -> void:
	if !pixelPerfectCamera || !mainCamera:
		return
	pixelPerfectCamera.set_global_transform(mainCamera.get_global_transform())
	
	pixelPerfectCamera.limit_top = mainCamera.limit_top
	pixelPerfectCamera.limit_bottom = mainCamera.limit_bottom
	pixelPerfectCamera.limit_right = mainCamera.limit_right
	pixelPerfectCamera.limit_left = mainCamera.limit_left
