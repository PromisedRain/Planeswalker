extends Control

@onready var slot1Container = $MarginContainer/Control2/MarginContainer/VBoxContainer/Slot1Container
@onready var slot2Container = $MarginContainer/Control2/MarginContainer/VBoxContainer/Slot2Container
@onready var slot3Container = $MarginContainer/Control2/MarginContainer/VBoxContainer/Slot3Container

var emptySlot: PackedScene = load("res://src/gui/slotSelectionComponents/emptySlot.tscn")
var usedSlot: PackedScene = load("res://src/gui/slotSelectionComponents/usedSlot.tscn")

signal selectedSlot(slot: int)
signal slotSelectionPressedReturn

func _ready() -> void:
	load_and_init_saved_slots_data()

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

func load_and_init_saved_slots_data() -> void:
	var saveFiles: Array = SaveManager.get_save_files()
	
	for i: int in 3: #loops 3 times
		var filename = "saveslot%s.json" % [i + 1] #it would then look for the savefiles 1 2 and 3.
		
		for file in saveFiles: # then it would loop over the saveFiles
			if file == filename: # then it would check if a file == filename which we know is 1 2 or 3.
				print("savefile found: %s" % [i + 1])
				instantiate_used_slot(int(i + 1))

func instantiate_used_slot(slot: int) -> void:
	var slotMetaData = SaveManager.get_slot_meta_data(slot)
	
	
	
	pass
	#var instance = usedSlot.new()
	

func _on_slot_selection_return_button_pressed() -> void:
	emit_signal("slotSelectionPressedReturn")

func _on_slot_delete_button_pressed() -> void:
	pass
