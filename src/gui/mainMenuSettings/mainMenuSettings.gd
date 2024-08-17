extends Control

signal mainMenuSettingsScreenPressedReturn


func _ready() -> void:
	pass # Replace with function body.


func _on_settings_return_button_pressed() -> void:
	mainMenuSettingsScreenPressedReturn.emit()
