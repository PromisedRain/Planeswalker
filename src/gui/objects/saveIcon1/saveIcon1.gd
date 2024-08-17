class_name SaveIcon1
extends Control

@onready var textureRect: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/TextureRect

const timerTime: float = 0.7

var timerTimer: float
var vanish: bool = false
var enter: bool = true

func _ready() -> void:
	textureRect.modulate.a = 0.0
	timerTimer = timerTime

func _physics_process(delta: float) -> void:
	if enter:
		textureRect.modulate.a = lerp(textureRect.modulate.a, 1.0, 0.125)
	
	if timerTimer > 0.0:
		timerTimer -= delta
	if Utils.is_approximately_equal(timerTimer, 0.01):
		enter = false
		vanish = true
	
	if vanish:
		textureRect.modulate.a = lerp(textureRect.modulate.a, 0.0, 0.125)
		if (textureRect.modulate.a < 0.01):
			SaveManager.savingFlag = false
			queue_free()
