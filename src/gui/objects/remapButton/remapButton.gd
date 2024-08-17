class_name RemapButton
extends Button

@export var action: String

func _init() -> void:
	toggle_mode = true
	#theme_type_variation = "RemapButton"

func _ready() -> void:
	set_process_unhandled_input(false)
	update_text()

func _toggled(button_pressed) -> void:
	if button_pressed:
		text = "..."
		release_focus()
	else:
		update_text()
		grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		InputMap.action_erase_event(action, event)
		InputMap.action_add_event(action, event)
		button_pressed = false

func update_text() -> void:
	text = "%s" % InputMap.action_get_events(action)[0].as_text()
