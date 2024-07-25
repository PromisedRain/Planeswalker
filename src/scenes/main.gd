extends Node

@onready var window: Window = get_window() 
@onready var baseSize: Vector2i = window.content_scale_size
@onready var screenSize: Vector2i = get_viewport().get_visible_rect().size

func ready() -> void: 
	print("screen size: %s" %screenSize)
	
	
	window.size_changed.connect(window_size_changed) 

# integer scaling no blackbox
func window_size_changed() -> void: 
	var scale: Vector2i = window.size/baseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

