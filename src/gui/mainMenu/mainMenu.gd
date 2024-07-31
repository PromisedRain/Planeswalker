extends Node2D

@onready var window: Window = get_window() 
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"CanvasLayer/StarParticles"

@onready var menuTitleScreen: Control = $CanvasLayer/TitleScreen
@onready var slotSelectionScreen: Control = $CanvasLayer/SlotSelection
@onready var settingsScreen: Control = $CanvasLayer/Settings
@onready var placeholderScreen: Control = $CanvasLayer/Placeholder


func _ready() -> void:
	start_star_particles()
	
	if !placeholderScreen.visible:
		placeholderScreen.visible = true
	
	hide_and_show_screens(placeholderScreen, menuTitleScreen)
	window.size_changed.connect(on_size_changed)

func start_star_particles() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	starParticles.emitting = true

func on_size_changed() -> void:
	# TODO get screen size in pixels based off of how big the screen actually is, currently doesnt work.
	starParticles.emission_rect_extents = windowScreenSize


func hide_and_show_screens(_hide: Control, _show: Control):
		_hide.visible = false
		_show.visible = true

#mainMenu buttons
func _on_title_screen_enter_pressed():
	hide_and_show_screens(menuTitleScreen, slotSelectionScreen)

func _on_title_screen_settings_pressed():
	hide_and_show_screens(menuTitleScreen, settingsScreen)

func _on_title_screen_quit_pressed():
	get_tree().quit()

#settings buttons
func _on_settings_return_button_pressed():
	hide_and_show_screens(settingsScreen, menuTitleScreen)

#slotSelection buttons
func _on_slot_selection_return_button_pressed():
	hide_and_show_screens(slotSelectionScreen, menuTitleScreen)

func _on_slot_1_select_pressed():
	print("[mainMenu] Slot 1 selected")
	var slotNum: int = 1
	verify_open_or_create_slot(slotNum)

func _on_slot_2_select_pressed():
	print("[mainMenu] Slot 2 selected")
	var slotNum: int = 2
	verify_open_or_create_slot(slotNum)

func _on_slot_3_select_pressed():
	print("[mainMenu] Slot 3 selected")
	var slotNum: int = 3
	verify_open_or_create_slot(slotNum)

func verify_open_or_create_slot(slot: int) -> void:
	var slotExists: bool = SaveManager.ensure_slot_file_exists(slot)
	match slotExists:
		true:
			SaveManager.load_slot(slot)
		false:
			SaveManager.save_slot(slot, SaveManager.create_default_slot_data_template())





