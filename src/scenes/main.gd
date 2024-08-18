extends Node

####################################################################
###                          main loop                           ###
####################################################################

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var world: Node2D = $SubViewport/World

#TODO remember to turn off on_top before shipping game cause its a problem, on top for debug only i guess guh

func _ready() -> void:
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	window.size_changed.connect(window_size_changed)
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
				#add_debug_mode_only_input_keys()
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
	if event.is_action_pressed("debug"):
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

func add_debug_mode_only_input_keys() -> void:
	if !InputMap.has_action("debug_reload_room"):
		InputMap.add_action("debug_reload_room")
		
		var keyEvent: InputEventKey = InputEventKey.new()
		#keyEvent.scancode = KEY_R
		InputMap.action_add_event("debug_reload_room", keyEvent)
		
		print("[main] Debug mode input added: %s", keyEvent)

func window_size_changed() -> void: 
	pass
	#print("size changed")
	#var scale: Vector2i = window.size / windowBaseSize 
	#window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)
