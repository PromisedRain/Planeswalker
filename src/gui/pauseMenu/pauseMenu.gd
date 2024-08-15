extends CanvasLayer

@export var layerIndex: LayerManager.Layers

func _ready() -> void:
	if layerIndex != LayerManager.Layers.PLACEHOLDER_LAYER:
		LayerManager.set_layer_index(self, layerIndex)



func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	#TODO make sure to save everything before quitting.
	SaveManager.save_game()
	LevelManager.reset_scene_loading_state()
	LevelManager.free_volume_instance()
	
	GlobalManager.canPause = false
	
	UiManager.instance_main_menu()
	UiManager.open_pause_menu(false) #closes it
	


func _on_quit_to_desktop_button_pressed():
	get_tree().quit()
