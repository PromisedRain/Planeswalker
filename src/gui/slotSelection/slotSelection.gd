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

func init_slots_data() -> void:
	var saveFiles: Array = SaveManager.get_save_dir_json_files()
	
	for i in range(1, 4):
		var expectedFilename: String = "savedata%d.json" % i
		var saveFound: bool = false
		
		for file: String in saveFiles:
			if file == expectedFilename:
				Utils.debug_print(self, "savedata found: %s", [i])
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
	instance.slot = slot
	if metaData["latest_volume_name"] != null:
		instance.slotCurrentVolumeName = metaData["latest_volume_name"]
	instance.slotCurrentVolume = metaData["current_volume"]
	instance.slotCollectibles = metaData["total_collectibles_collected"]
	instance.slotPlaytime = metaData["total_slot_playtime"]
	instance.slotDeaths = metaData["total_slot_deaths"]
	instance.slotPressed.connect(on_used_slot_pressed)
	instance.update_ui()
	
	var container: Control = slotContainers.get(slot, null)
	if container: #&& container.get_child_count() <= 0:
		container.add_child(instance)
	else:
		Utils.debug_print(self, "container '%d' already used", [slot])

func on_used_slot_pressed(slot: int) -> void:
	load_save(slot)
	selectedSlot.emit(slot)
	Utils.debug_print(self, "selected slot %d", [slot])

func instantiate_empty_slot(slot: int) -> void:
	var instance: EmptySlot = emptySlot.instantiate()
	instance.slot = slot
	instance.slotPressed.connect(on_empty_slot_pressed)
	
	var container: Control = slotContainers.get(slot, null)
	if container: #&& container.get_children().size() <= 0:
		container.add_child(instance)
	else:
		Utils.debug_print(self, "error 'containerSlot%d' not found / invalid", [slot])

func on_empty_slot_pressed(slot: int) -> void:
	instantiate_used_slot(slot)
	load_save(slot)
	SaveManager.currentSlotData = {}
	#selectedSlot.emit(slot)

func _on_slot_selection_return_button_pressed() -> void:
	slotSelectionPressedReturn.emit()

func load_save(slot: int) -> void:
	var slotExists: bool = SaveManager.ensure_slot_file_exists(slot)
	
	match slotExists:
		true:
			Utils.debug_print(self, "loading saved slot data")
			SaveManager.currentSlotData = SaveManager.load_slot(slot)
		false:
			Utils.debug_print(self, "creating new slot data")
			SaveManager.save_slot(slot, SaveManager.create_default_slot_data_template(slot))
			SaveManager.currentSlotData = SaveManager.load_slot(slot)

func _on_slot_erase_button_pressed() -> void:
	for slot: int in range(1, 4):
		SaveManager.delete_save_file("savedata", slot)
		SaveManager.delete_slot_meta_data(slot)
		var container = slotContainers.get(slot, null)
		var containerChildren = container.get_children()
		for child in containerChildren:
			child.queue_free()
	init_slots_data()
