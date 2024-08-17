class_name EmptySlot
extends Control

var slot: int

signal slotPressed(slot: int)


func _on_button_pressed() -> void:
	slotPressed.emit(slot)
	queue_free()
