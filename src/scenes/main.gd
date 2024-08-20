extends Node

####################################################################
###                       welcome to main\n                      ###
####################################################################

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var world: Node2D = $SubViewport/World

var env: Dictionary = {}

signal filePathInvalid(path: String)

func _ready() -> void:
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	window.size_changed.connect(window_size_changed)
	self.filePathInvalid.connect(on_file_path_invalid)
	SignalManager.initialLoadComplete.connect(init)
	
	var saveSecurityKey: String
	
	ensure_env_file_exists(".env")
	
	if load_env_file(".env"):
		saveSecurityKey = env.get("SAVE_SECURITY_KEY")
	else:
		saveSecurityKey = "ERROR_GETTING_SAVE_SECURITY_KEY"
		Utils.debug_print(self, "failed to load SAVE_SECURITY_KEY from .env, using fallback.")
		print("[main] Failed to load SAVE_SECURITY_KEY from .env, using fallback.")
	
	SaveManager.init(saveSecurityKey)

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

func load_env_file(_path: String) -> bool:
	var dir: DirAccess = SaveManager.verify_and_open_dir(_path)
	
	if !FileAccess.file_exists(_path):
		filePathInvalid.emit(_path)
		return false
	
	var file: FileAccess = FileAccess.open(_path, FileAccess.READ)
	
	if !file:
		Utils.debug_print(self, "error opening the file for reading at: %s", [_path])
		return false
	else:
		var data = file.get_as_text()
		file.close()
		return load_env_data(data)

func load_env_data(envData: String) -> bool:
	var lines: PackedStringArray = envData.split("\n", true)
	
	for line in lines:
		if line.find("=") != -1 && !line.begins_with("#"):
			var keyValue = line.split("=", false)
			
			if keyValue.size() == 2:
				var key: String = keyValue[0].strip_edges()
				var value: String = keyValue[1].strip_edges()
				env[key] = value
	return true

func ensure_env_file_exists(_path: String) -> bool:
	if !FileAccess.file_exists(_path):
		Utils.debug_print(self, ".env file not created, creating at: %s", [_path])
		generate_env_file(".env")
		return false
	return true

func generate_env_file(_path: String) -> bool:
	var file: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	
	if !file:
		filePathInvalid.emit(_path)
		return false
	else:
		file.store_line("# default .env configuration")
		file.store_line("")
		file.store_line("SAVE_SECURITY_KEY=%s" % Utils.generate_uuid().to_upper())
		file.close()
		return true

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug") && GlobalManager.debugMode:
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

func window_size_changed() -> void: 
	pass
	#print("size changed")
	#var scale: Vector2i = window.size / windowBaseSize 
	#window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

func on_file_path_invalid(filePath) -> void:
	Utils.debug_print(self, "cannot open non-existent file at: %s", [filePath])
