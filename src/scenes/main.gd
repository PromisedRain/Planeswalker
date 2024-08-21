extends Node

####################################################################
###                       welcome to main\n                      ###
####################################################################

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size

@onready var world: Node2D = $SubViewport/World

signal filePathInvalid(path: String)

func _ready() -> void:
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	window.size_changed.connect(window_size_changed)
	self.filePathInvalid.connect(on_file_path_invalid)
	SignalManager.initialLoadComplete.connect(init)
	
	SaveManager.init()

func init(loaded: bool) -> void: 
	if !loaded:
		Utils.debug_print(self, "init failed to load")
		return
	
	if SaveManager.get_config_data("settings_special", "debug_mode") != null:
		var data: bool = SaveManager.get_config_data("settings_special", "debug_mode")
		
		match data:
			true:
				GlobalManager.debugMode = true
			false:
				GlobalManager.debugMode = false
		Utils.debug_print(self, "debug mode: %s", [data])
	
	LevelManager.init(self, world)
	UiManager.init()
	
	#match LevelManager.currentVolume:
	#	"volume1":
	#		print("volume 1")
	#	_:
	#		print("volume ???")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug") && GlobalManager.debugMode:
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

func window_size_changed() -> void: 
	pass
	#var scale: Vector2i = window.size / windowBaseSize 
	#window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

func on_file_path_invalid(filePath) -> void:
	Utils.debug_print(self, "cannot open non-existent file at: %s", [filePath])
