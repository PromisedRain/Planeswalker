class_name SettingsVideo
extends VBoxContainer

@onready var fullScreenButton: Button = $FullScreenButton
@onready var borderlessButton: Button = $BorderlessButton
@onready var vSyncButton: Button = $VSyncButton
@onready var screenShakeButton: Button = $ScreenShakeButton

#signal fullScreenButtonPressed
#signal borderlessButtonPressed
#signal vSyncButtonPressed
#signal screenShakeButtonPressed

var buttonEnabled: String = "<on>"
var buttonDisabled: String = "<off>"

func _ready() -> void:
	load_current_settings()

func load_current_settings() -> void:
	if SaveManager.get_config_data("settings_video", "fullscreen") != null:
		var data: bool = SaveManager.get_config_data("settings_video", "fullscreen")
		
		match data:
			true:
				fullScreenButton.text = buttonEnabled
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			false:
				fullScreenButton.text = buttonDisabled
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Utils.debug_print(self, "fullscreen: %s", [data])
	
	if SaveManager.get_config_data("settings_video", "borderless") != null:
		var data: bool = SaveManager.get_config_data("settings_video", "borderless")
		
		match data:
			true:
				borderlessButton.text = buttonEnabled
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			false:
				borderlessButton.text = buttonDisabled
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Utils.debug_print(self, "borderless: %s", [data])
	
	if SaveManager.get_config_data("settings_video", "v_sync") != null:
		var data: bool = SaveManager.get_config_data("settings_video", "v_sync")
		
		match data:
			true:
				vSyncButton.text = buttonEnabled
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			false:
				vSyncButton.text = buttonDisabled
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Utils.debug_print(self, "v sync: %s", [data])
	
	if SaveManager.get_config_data("settings_video", "screen_shake") != null:
		var data: bool = SaveManager.get_config_data("settings_video", "screen_shake")
		
		match data:
			true:
				CameraManager.screenShakeEnabled = true
			false:
				CameraManager.screenShakeEnabled = false
		Utils.debug_print(self, "screen shake: %s", [data])

func _on_full_screen_button_pressed() -> void:
	
	
	pass
	#fullScreenButtonPressed.emit()

func _on_borderless_button_pressed() -> void:
	pass
	#borderlessButtonPressed.emit()

func _on_v_sync_button_pressed() -> void:
	pass
	#vSyncButtonPressed.emit()

func _on_screen_shake_button_pressed() -> void:
	pass
	#screenShakeButtonPressed.emit()
