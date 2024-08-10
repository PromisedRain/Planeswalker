extends CanvasLayer

@onready var window: Window = get_window() 
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"StarParticles"

@onready var titleScreen: Control = $TitleScreen
@onready var settingsScreen: Control = $Settings
@onready var slotSelectionScreen: Control = $SlotSelection
@onready var volumeSelectionScreen: Control = $VolumeSelection

signal chosenVolumeFromMainMenu(volume: int)

func _ready() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	if !starParticles.emitting:
		starParticles.emitting = true
	
	if !titleScreen.visible:
		titleScreen.visible = true
	
	#signals
	window.size_changed.connect(window_on_size_change)
	
	titleScreen.titleScreenPressedEnter.connect(title_screen_pressed_enter)
	titleScreen.titleScreenPressedSettings.connect(title_screen_pressed_settings)
	titleScreen.titleScreenPressedQuit.connect(title_screen_pressed_quit)
	
	slotSelectionScreen.selectedSlot.connect(slot_selection_screen_selected_slot)
	slotSelectionScreen.slotSelectionPressedReturn.connect(slot_selection_screen_pressed_return)
	
	settingsScreen.mainMenuSettingsScreenPressedReturn.connect(main_menu_settings_screen_pressed_return)
	
	volumeSelectionScreen.volumeSelectionPressedReturn.connect(volume_selection_screen_pressed_return)

func window_on_size_change() -> void:
	starParticles.emission_rect_extents = windowScreenSize

#titlescreen
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

#slotselection
func slot_selection_screen_selected_slot(_slot: int) -> void:
	if slotSelectionScreen.visible:
		slotSelectionScreen.visible = false
	if !volumeSelectionScreen.visible:
		volumeSelectionScreen.visible = true

func slot_selection_screen_pressed_return() -> void:
	if slotSelectionScreen.visible:
		slotSelectionScreen.visible = false
	if !titleScreen.visible:
		titleScreen.visible = true

#volumeselection
func volume_selection_screen_pressed_return() -> void:
	if volumeSelectionScreen.visible:
		volumeSelectionScreen.visible = false
	if !slotSelectionScreen.visible:
		slotSelectionScreen.visible = true
	SaveManager.currentSlotData = {}

#mainMenuSettings
func main_menu_settings_screen_pressed_return() -> void:
	if settingsScreen.visible:
		settingsScreen.visible = false
	if !titleScreen.visible:
		titleScreen.visible = true
