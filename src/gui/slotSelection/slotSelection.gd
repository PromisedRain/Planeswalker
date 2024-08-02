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
	var metaData: Dictionary = SaveManager.get_all_slot_meta_data(slot)
	var instance: UsedSlot = usedSlot.instantiate()
	print("type shi")
	instance.slot = slot
	instance.slotCurrentVolume = metaData["current_volume"]
	instance.slotCollectibles = metaData["total_collectibles_collected"]
	instance.slotPlaytime = metaData["total_slot_playtime"]
	instance.slotDeaths = metaData["total_slot_deaths"]
	instance.slotPressed.connect(on_used_slot_pressed)
	
	var container: Control = get_slot_container(slot)
	if container && container.get_children().size() <= 0:
		container.add_child(instance)

func on_used_slot_pressed(slot: int) -> void:
	pass

func instantiate_empty_slot(slot: int) -> void:
	var instance: EmptySlot = emptySlot.instantiate()
	instance.slot = slot
	instance.slotPressed.connect(on_empty_slot_pressed)
	
	var container: Control = get_slot_container(slot)
	if container && container.get_children().size() <= 0:
		container.add_child(instance)
	else:
		print("[slotSelection] Error 'containerSlot%d' not found" % slot)

func on_empty_slot_pressed(slot: int) -> void:
	print("type shii %s" % slot)
	instantiate_used_slot(slot)
	open_or_create_slot(slot)

func get_slot_container(slot: int) -> Control:
	return slotContainers.get(slot, null)

func _on_slot_selection_return_button_pressed() -> void:
	emit_signal("slotSelectionPressedReturn")

func _on_slot_delete_button_pressed() -> void:
	pass
