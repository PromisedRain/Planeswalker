extends CanvasLayer

@export var playerUi: PackedScene
@export var debugManager: PackedScene 
@export var mainMenu: PackedScene
@export var slotSelection: PackedScene

@onready var vignette: CanvasLayer = $Vignette
@onready var pauseMenu: CanvasLayer = $PauseMenu

var loadedComponents: Dictionary = {}


func _ready() -> void:
	init_vignette()
	init_main_menu()
	init_debug_manager()

func _process(delta: float) -> void:
	pass

func init_main_menu() -> void:
	open_ui_component("mainMenu", mainMenu, true)

func free_main_menu() -> void:
	free_ui_component("mainMenu")

func open_slot_selection() -> void:
	open_ui_component("slotSelection", slotSelection, true)

func free_slot_selection() -> void:
	free_ui_component("slotSelection")

func init_vignette() -> void:
	vignette.visible = true
	var colorRect: ColorRect = vignette.get_node("ColorRect")
	colorRect.material.set_shader_parameter("Vignette Opacity", lerp(0.5, 0.261, 0.50))

func init_debug_manager() -> void:
	open_ui_component("debugManager", debugManager, false)

func open_debug_mode() -> void:
	if debugManager == null:
		return
	#open mode
	if !debugManager.visible && canDebug:
		print("[console] debug on")
		debugManager.visible = true
	
	#close mode
	elif debugManager.visible:
		print("[console] debug off")
		debugManager.visible = false

func open_pause_menu() -> void:
	if !pauseMenu.visible && canPause:
		print("[console] pause on")
		pauseMenu.visible = true
		get_tree().paused = true
	
	elif pauseMenu.visible:
		print("[console] pause off")
		pauseMenu.visible = false
		get_tree().paused = false

func open_ui_component(name: String, component: PackedScene, showOnready: bool) -> void:
	if !loadedComponents.has(name):
		var instance = component.instantiate()
		loadedComponents[name] = instance
		add_child(instance)
		if instance is CanvasLayer:
			instance.hide() 
		elif instance is Node2D:
			instance.visible = false
	
	if !showOnready:
		return
	
	if loadedComponents[name] is CanvasLayer:
		loadedComponents[name].show()
	elif loadedComponents[name] is Node2D:
		loadedComponents[name].visible = true


func free_ui_component(name: String) -> void:
	if loadedComponents.has(name):
		var instance = loadedComponents[name]
		instance.queue_free()
		loadedComponents.erase(name)

#getters
var canPause: bool:
	get:
		return true

var canDebug: bool:
	get:
		return true
