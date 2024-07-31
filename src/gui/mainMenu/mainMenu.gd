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
	# TODO get screen size in pixels based off of how big the screen actually is, 
	# so i can apply stars everywhere
	starParticles.emission_rect_extents = windowScreenSize


func hide_and_show_screens(hide: Control, show: Control):
		hide.visible = false
		show.visible = true

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
	pass

func _on_slot_2_select_pressed():
	pass

func _on_slot_3_select_pressed():
	pass


