class_name EmptySlot
extends Control

signal emptySlotPressed

func _ready():
	pass



func _on_button_pressed() -> void:
	emit_signal("emptySlotPressed")
	print("empty slot")
