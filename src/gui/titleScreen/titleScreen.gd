extends Control

signal titleScreenPressedEnter
signal titleScreenPressedSettings
signal titleScreenPressedQuit


func _on_title_screen_enter_pressed() -> void:
	emit_signal("titleScreenPressedEnter")

func _on_title_screen_settings_pressed() -> void:
	emit_signal("titleScreenPressedSettings")

func _on_title_screen_quit_pressed() -> void:
	emit_signal("titleScreenPressedQuit")
