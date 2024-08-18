extends Control

@onready var settingsControls: SettingsControls = $MarginContainer/Control/MarginContainer/ScrollContainer/VBoxContainer/SettingsControls
@onready var settingsVideo: SettingsVideo = $MarginContainer/Control/MarginContainer/ScrollContainer/VBoxContainer/SettingsVideo
#@onready var settingsAudio: VBoxContainer = $MarginContainer/Control/MarginContainer/ScrollContainer/VBoxContainer/SettingsAudio
@onready var settingsSpecial: SettingsSpecial = $MarginContainer/Control/MarginContainer/ScrollContainer/VBoxContainer/SettingsSpecial


signal mainMenuSettingsScreenPressedReturn

func _ready() -> void:
	pass

func _on_settings_return_button_pressed() -> void:
	mainMenuSettingsScreenPressedReturn.emit()
