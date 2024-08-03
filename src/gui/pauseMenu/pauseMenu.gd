extends CanvasLayer


func _ready() -> void:
	pass 



func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	UiManager.instance_main_menu()
	UiManager.open_pause_menu()
	LevelManager.free_world_instance()

func _on_quit_to_desktop_button_pressed():
	get_tree().quit()
