class_name SettingsControls
extends VBoxContainer

@onready var keyboardInputsButton = $KeyboardInputsButton

signal keyboardInputsButtonPressed

func _on_keyboard_inputs_button_pressed() -> void:
	keyboardInputsButtonPressed.emit()
