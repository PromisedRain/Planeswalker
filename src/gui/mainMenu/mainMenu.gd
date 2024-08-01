extends Node2D

@onready var window: Window = get_window() 
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"CanvasLayer/StarParticles"

@onready var titleScreen: Control = $CanvasLayer/TitleScreen
@onready var slotSelectionScreen: Control = $CanvasLayer/SlotSelection
@onready var settingsScreen: Control = $CanvasLayer/Settings


func _ready() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	if !starParticles.emitting:
		starParticles.emitting = true
	
	if !titleScreen.visible:
		titleScreen.visible = true
	
	#signals
	window.size_changed.connect(on_size_changed)
	
	titleScreen.titleScreenPressedEnter.connect(title_screen_pressed_enter)
	titleScreen.titleScreenPressedSettings.connect(title_screen_pressed_settings)
	titleScreen.titleScreenPressedQuit.connect(title_screen_pressed_quit)
	
	#slotSelectionScreen.selectedSlot.connect(slot_selection_screen_selected_slot)
	slotSelectionScreen.slotSelectionPressedReturn.connect(slot_selection_screen_pressed_return)
	
	settingsScreen.mainMenuSettingsScreenPressedReturn.connect(main_menu_settings_screen_pressed_return)

func title_screen_pressed_enter() -> void:
	if !slotSelectionScreen.visible:
		slotSelectionScreen.visible = true
	if titleScreen.visible:
		titleScreen.visible = false

func title_screen_pressed_settings() -> void:
	if !settingsScreen.visible:
		settingsScreen.visible = true
	if titleScreen.visible:
		titleScreen.visible = false

func title_screen_pressed_quit() -> void:
	get_tree().quit()

func slot_selection_screen_selected_slot(slot: int) -> void:
	pass

func slot_selection_screen_pressed_return() -> void:
	if slotSelectionScreen.visible:
		slotSelectionScreen.visible = false
	if !titleScreen.visible:
		titleScreen.visible = true

func main_menu_settings_screen_pressed_return() -> void:
	if settingsScreen.visible:
		settingsScreen.visible = false
	if !titleScreen.visible:
		titleScreen.visible = true

func on_size_changed() -> void:
	starParticles.emission_rect_extents = windowScreenSize
