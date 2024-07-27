extends Node2D


signal playButtonPressed

func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	emit_signal("playButtonPressed")
