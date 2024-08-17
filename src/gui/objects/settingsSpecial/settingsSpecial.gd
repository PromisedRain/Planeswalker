extends VBoxContainer

@onready var vignetteButton: Button = $VignetteButton
@onready var debugModeButton: Button = $DebugModeButton

signal vignetteButtonPressed
signal debugModeButtonPressed

func _on_vignette_button_pressed():
	vignetteButtonPressed.emit()

func _on_debug_mode_button_pressed():
	debugModeButtonPressed.emit()
