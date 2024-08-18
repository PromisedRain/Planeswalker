class_name SettingsSpecial
extends VBoxContainer

@onready var vignetteButton: Button = $VignetteButton
@onready var debugModeButton: Button = $DebugModeButton
@onready var gameTimerButton: Button = $GameTimerButton
@onready var debugFpsButton: Button = $DebugFpsButton
@onready var debugSettingsOnlyLabel: VBoxContainer = $VBoxContainer2

var buttonEnabled: String = "<on>"
var buttonDisabled: String = "<off>"

func _ready() -> void:
	load_current_settings()
	check_and_load_debug_exlusive_settings()

func load_current_settings() -> void:
	update_vignette_button()
	update_game_timer_button()
	update_debug_mode_button()

func update_vignette_button() -> void:
	if SaveManager.get_config_data("settings_special", "vignette") != null:
		var data: bool = SaveManager.get_config_data("settings_special", "vignette")
		
		match data:
			true:
				vignetteButton.text = buttonEnabled
			false:
				vignetteButton.text = buttonDisabled

func update_game_timer_button() -> void:
	if SaveManager.get_config_data("settings_special", "game_timer") != null:
		var data: bool = SaveManager.get_config_data("settings_special", "game_timer")
		
		match data:
			true:
				gameTimerButton.text = buttonEnabled
			false:
				gameTimerButton.text = buttonDisabled

func update_debug_mode_button() -> void:
	if SaveManager.get_config_data("settings_special", "debug_mode") != null:
		var data: bool = SaveManager.get_config_data("settings_special", "debug_mode")
		
		match data:
			true:
				debugModeButton.text = buttonEnabled
			false:
				debugModeButton.text = buttonDisabled
		check_and_load_debug_exlusive_settings()
		#Utils.debug_print(self, "debug mode: %s", [data])

func check_and_load_debug_exlusive_settings() -> void:
	if GlobalManager.debugMode != null:
		var _visible: bool = GlobalManager.debugMode
		
		debugFpsButton.visible = _visible
		debugSettingsOnlyLabel.visible = _visible

func _on_vignette_button_pressed() -> void:
	pass

func _on_debug_mode_button_pressed() -> void:
	if GlobalManager.debugMode != null:
		var data: bool = GlobalManager.debugMode
		
		match data:
			true:
				SaveManager.set_config_data("settings_special", "debug_mode", false)
				GlobalManager.debugMode = false
			false:
				SaveManager.set_config_data("settings_special", "debug_mode", true)
				GlobalManager.debugMode = true
		update_debug_mode_button()





#violet evergarden got me fucked up bruh :sob:
