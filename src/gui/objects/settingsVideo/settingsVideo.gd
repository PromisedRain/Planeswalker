extends VBoxContainer

@onready var fullScreenButton: Button = $FullScreenButton
@onready var borderlessButton: Button = $BorderlessButton
@onready var exclusiveFullScreenButton: Button = $ExclusiveFullScreenButton
@onready var vSyncButton: Button = $VSyncButton
@onready var screenShakeButton: Button = $ScreenShakeButton

signal fullScreenButtonPressed
signal borderlessButtonPressed
signal exclusiveFullScreenButtonPressed
signal vSyncButtonPressed
signal screenShakeButtonPressed

func _on_full_screen_button_pressed():
	fullScreenButtonPressed.emit()

func _on_borderless_button_pressed():
	borderlessButtonPressed.emit()

func _on_exclusive_full_screen_button_pressed():
	exclusiveFullScreenButtonPressed.emit()

func _on_v_sync_button_pressed():
	vSyncButtonPressed.emit()

func _on_screen_shake_button_pressed():
	screenShakeButtonPressed.emit()
