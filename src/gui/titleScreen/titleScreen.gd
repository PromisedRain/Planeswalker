extends Control

signal titleScreenPressedEnter
signal titleScreenPressedSettings
signal titleScreenPressedQuit


func _on_title_screen_enter_pressed() -> void:
	titleScreenPressedEnter.emit()

func _on_title_screen_settings_pressed() -> void:
	titleScreenPressedSettings.emit()

func _on_title_screen_quit_pressed() -> void:
	titleScreenPressedQuit.emit()
