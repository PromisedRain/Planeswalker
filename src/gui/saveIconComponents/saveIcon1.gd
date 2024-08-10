class_name SaveIcon1
extends Sprite2D

const timerTime: float = 0.7

var timerTimer: float
var vanish: bool = false
var enter: bool = true

func _ready() -> void:
	modulate.a = 0.0
	timerTimer = timerTime

func _physics_process(delta: float) -> void:
	if enter:
		modulate.a = lerp(modulate.a, 1.0, 0.125)
	
	if timerTimer > 0.0:
		timerTimer -= delta
	if Utils.is_approximately_equal(timerTimer, 0.01):
		enter = false
		vanish = true
	
	if vanish:
		modulate.a = lerp(modulate.a, 0.0, 0.125)
		if (modulate.a < 0.01):
			queue_free()
