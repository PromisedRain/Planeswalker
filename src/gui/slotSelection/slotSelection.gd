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
	var saveFiles: Array = SaveManager.get_dir_json_files()
	
	for i in range(1, 4):
		var expectedFilename: String = "savedata%d.json" % i
		var saveFound: bool = false
		
		for file: String in saveFiles:
			if file == expectedFilename:
				print("[slotSelection] Savedata found: %d" % i)
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
		print("container%s already used" % slot)

func on_used_slot_pressed(slot: int) -> void:
	load_save(slot)
	selectedSlot.emit(slot)
	print("[slotSelection] Selected slot_%d" % slot)

func instantiate_empty_slot(slot: int) -> void:
	var instance: EmptySlot = emptySlot.instantiate()
	instance.slot = slot
	instance.slotPressed.connect(on_empty_slot_pressed)
	
	var container: Control = slotContainers.get(slot, null)
	if container: #&& container.get_children().size() <= 0:
		container.add_child(instance)
	else:
		print("[slotSelection] Error 'containerSlot%d' not found" % slot)

func on_empty_slot_pressed(slot: int) -> void:
	instantiate_used_slot(slot)
	load_save(slot)
	SaveManager.currentSlotData = {}

func _on_slot_selection_return_button_pressed() -> void:
	slotSelectionPressedReturn.emit()

func load_save(slot: int) -> void:
	var slotExists: bool = SaveManager.ensure_slot_file_exists(slot)
	match slotExists:
		true:
			SaveManager.currentSlotData = SaveManager.load_slot(slot)
		false:
			SaveManager.save_slot(slot, SaveManager.create_default_slot_data_template(slot))
			SaveManager.currentSlotData = SaveManager.load_slot(slot)

func _on_slot_erase_button_pressed() -> void:
	for slot: int in range(1, 4):
		SaveManager.delete_save_file("savedata", slot)
		var container = slotContainers.get(slot, null)
		var containerChildren = container.get_children()
		for child in containerChildren:
			child.queue_free()
	init_slots_data()
