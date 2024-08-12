extends Node

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var world: Node2D = $SubViewport/World

#TODO remember to turn off on_top before shipping game cause its a problem, on top for debug only i guess guh

func _ready() -> void:
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	window.size_changed.connect(window_size_changed)
	SignalManager.initLoadComplete.connect(init)
	
	SaveManager.init()

func init(loaded: bool) -> void: 
	if !loaded:
		return
	
	if SaveManager.get_config_data("settings", "debug_mode") != null:
		GlobalManager.debugMode = SaveManager.get_config_data("settings", "debug_mode")
		
		if GlobalManager.debugMode:
			print("[main] Debug mode on")
		else:
			print("[main] Debug mode off")
	
	LevelManager.init(self, world)
	UiManager.init()
	
	#match LevelManager.currentVolume:
	#	"volume1":
	#		print("volume 1")
	#	_:
	#		print("volume ???")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug"):
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

func window_size_changed() -> void: 
	return
	print("size changed")
	var scale: Vector2i = window.size / windowBaseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)
