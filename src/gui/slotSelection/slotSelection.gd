extends Control

@onready var slotContainers: Dictionary = {
	1: $MarginContainer/Control2/MarginContainer/VBoxContainer/SlotContainer1,
	2: $MarginContainer/Control2/MarginContainer/VBoxContainer/SlotContainer2,
	3: $MarginContainer/Control2/MarginContainer/VBoxContainer/SlotContainer3
}


@onready var usedSlot: PackedScene = preload("res://src/gui/slotSelectionComponents/usedSlot.tscn")
@onready var emptySlot: PackedScene = preload("res://src/gui/slotSelectionComponents/emptySlot.tscn")

signal selectedSlot(slot: int)
signal slotSelectionPressedReturn

func _ready() -> void:
	init_slots_data()

#func _process(delta: float) -> void:
#	pass




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
			SaveManager.save_slot(slot, SaveManager.create_default_slot_data_template(slot))
			SaveManager.save_meta_data(slot, SaveManager.create_default_meta_data_template(slot))

func init_slots_data() -> void:
	var saveFiles: Array = SaveManager.get_dir_json_files()
	
	for i in range(1, 4):
		var expectedFilename: String = "savedata%d.json" % i
		var saveFound: bool = false
		
		for file: String in saveFiles:
			if file == expectedFilename:
				print("savedata found: %d" % i)
				instantiate_used_slot(i)
				saveFound = true
				break
		
		if !saveFound:
			var noMetadata: bool = false
			
			for file: String in saveFiles:
				if file.begins_with("metadata"):
					noMetadata = true
					break
			if noMetadata:
				instantiate_empty_slot(i)

func instantiate_used_slot(slot: int) -> void:
	var slotMetaData = SaveManager.get_all_slot_meta_data(slot)
	
	var container: Control = get_slot_container(slot)
	print(container)

func instantiate_empty_slot(slot: int) -> void:
	var instance: EmptySlot = emptySlot.instantiate()
	instance.slot = slot
	
	var container: Control = get_slot_container(slot)
	if container:
		container.add_child(instance)
	else:
		print("[slotSelection] Error containerSlot%d not found" % slot)
	
	print("added empty slot at %s" % slot)

func get_slot_container(slot: int) -> Control:
	return slotContainers.get(slot, null)

func _on_slot_selection_return_button_pressed() -> void:
	emit_signal("slotSelectionPressedReturn")

func _on_slot_delete_button_pressed() -> void:
	pass
