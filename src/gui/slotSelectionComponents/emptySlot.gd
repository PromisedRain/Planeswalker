class_name EmptySlot
extends Control

var slot: int

signal slotPressed(slot: int)


func _on_button_pressed() -> void:
	emit_signal("slotPressed", slot)
	queue_free()
	#print("pressed %s" % slot)
