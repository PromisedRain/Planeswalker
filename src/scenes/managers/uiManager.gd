extends CanvasLayer

@export var playerUi: PackedScene
@export var debugManager: PackedScene 
@export var mainMenu: PackedScene

@onready var vignette: CanvasLayer = $Vignette
@onready var pauseMenu: CanvasLayer = $PauseMenu

var loaded: Dictionary = {}

const scenesDict: Dictionary = {
	mainMenu = "mainMenu",
	debugManager = "debugManager"
}

func init() -> void:
	instance_vignette()
	instance_main_menu()
	open_ui_component(scenesDict.debugManager, debugManager, false)

func instance_main_menu() -> void:
	open_ui_component(scenesDict.mainMenu, mainMenu, true)

func free_main_menu() -> void:
	free_ui_component(scenesDict.mainMenu)

func instance_vignette() -> void:
	if SaveManager.get_config_data("settings", "vignette_visible"):
		vignette.visible = true
		var colorRect: ColorRect = vignette.get_node("ColorRect")
		colorRect.material.set_shader_parameter("Vignette Opacity", lerp(0.5, 0.261, 0.50))
	else:
		print("[HUD] Vignette off")

func open_debug_mode() -> void:
	if loaded[scenesDict.debugManager] == null:
		return
	
	if !loaded[scenesDict.debugManager].visible:
		print("[HUD] Debug on")
		loaded[scenesDict.debugManager].visible = true
	
	elif loaded[scenesDict.debugManager].visible:
		print("[HUD] Debug off")
		loaded[scenesDict.debugManager].visible = false

func open_pause_menu() -> void:
	if pauseMenu == null:
		return
	
	if !pauseMenu.visible:
		print("[HUD] Pause on")
		pauseMenu.visible = true
		get_tree().paused = true
	
	elif pauseMenu.visible:
		print("[HUD] Pause off")
		pauseMenu.visible = false
		get_tree().paused = false

func open_ui_component(_name: String, component: PackedScene, showOnready: bool) -> void:
	if !loaded.has(_name):
		var node = component.instantiate()
		loaded[_name] = node
		add_child(node)
		if node is CanvasLayer:
			node.hide() 
		elif node is Node2D:
			node.visible = false
	
	if !showOnready:
		return
	
	var instance = loaded[_name]
	if instance is CanvasLayer:
		instance.show()
	elif instance is Node2D:
		instance.visible = true

func free_ui_component(_name: String) -> void:
	if loaded.has(_name):
		var instance = loaded[_name]
		instance.queue_free()
		loaded.erase(_name)

#getters

