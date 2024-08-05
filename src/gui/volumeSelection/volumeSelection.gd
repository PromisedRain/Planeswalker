extends Control

signal volumeSelectionPressedReturn

func _ready() -> void:
	pass 

func init_selectable_volumes() -> void:
	pass



func _on_volume_selection_return_button_pressed() -> void:
	volumeSelectionPressedReturn.emit()


func _on_volume_1_button_pressed():
	UiManager.free_main_menu()
	LevelManager.change_current_volume(LevelManager.Volumes.volume1)
	
