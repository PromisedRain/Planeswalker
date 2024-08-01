extends Control

signal selectedSlot(slot: int)
signal slotSelectionPressedReturn

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass




func _on_slot_1_select_pressed() -> void:
	print("[mainMenu] Slot 1 selected")
	var slot: int = 1
	open_or_create_slot(slot)
	emit_signal("selectedSlot", slot)

func _on_slot_2_select_pressed() -> void:
	print("[mainMenu] Slot 2 selected")
	var slot: int = 2
	open_or_create_slot(slot)
	emit_signal("selectedSlot", slot)

func _on_slot_3_select_pressed() -> void:
	print("[mainMenu] Slot 3 selected")
	var slot: int = 3
	open_or_create_slot(slot)
	emit_signal("selectedSlot", slot)

func open_or_create_slot(slot: int) -> void:
	var slotExists: bool = SaveManager.ensure_slot_file_exists(slot)
	match slotExists:
		true:
			SaveManager.load_slot(slot)
		false:
			SaveManager.save_slot(slot, SaveManager.create_default_slot_data_template())
			SaveManager.save_meta_data(slot, SaveManager.create_default_meta_data_template())

func _on_slot_selection_return_button_pressed() -> void:
	emit_signal("slotSelectionPressedReturn")
