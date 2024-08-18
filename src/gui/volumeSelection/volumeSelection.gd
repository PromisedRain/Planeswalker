extends Control

signal volumeSelectionPressedReturn

func _ready() -> void:
	init_selectable_volumes()

func init_selectable_volumes() -> void:
	pass

func _on_volume_selection_return_button_pressed() -> void:
	volumeSelectionPressedReturn.emit()

func _on_volume_1_button_pressed():
	UiManager.free_main_menu()
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	GlobalManager.canPause = true
	SignalManager.signal_choosing_volume(SignalManager.Volumes.volume1)
