extends CanvasLayer

@onready var vignette: CanvasLayer = $Vignette
@onready var pauseMenu: CanvasLayer = $PauseMenu
@onready var main: Node = Utils.get_main()

@export var playerUi: PackedScene
@export var debugManager: PackedScene 
@export var mainMenu: PackedScene



var loaded: Dictionary = {}

var scenesDict: Dictionary = {
	"mainMenu": "mainMenu",
	"debugManager": "debugManager"
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
		print("[uiManager] Vignette off")

func open_debug_mode() -> void:
	if loaded[scenesDict.debugManager] == null:
		return
	
	if !loaded[scenesDict.debugManager].visible:
		print("[uiManager] Debug on")
		loaded[scenesDict.debugManager].visible = true
	
	elif loaded[scenesDict.debugManager].visible:
		print("[uiManager] Debug off")
		loaded[scenesDict.debugManager].visible = false

func open_pause_menu(hideMouse: bool) -> void:
	if pauseMenu == null:
		return
	
	#open menu
	if !pauseMenu.visible && canPause:
		print("[uiManager] Paused")
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pauseMenu.visible = true
		get_tree().paused = true
	
	#close menu
	elif pauseMenu.visible:
		print("[uiManager] Not paused")
		#Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		if hideMouse:
			pass
			#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
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
var canPause: bool:
	get:
		return check_if_main_screen()

var canDebug: bool:
	get: 
		return check_if_main_screen()

func check_if_main_screen() -> bool:
	if main.get_node("Volume").get_children().size() > 0: #checks if a volume is instantiated 
		print("[uiManager] Can pause")
		return true
	else:
		print("[uiManager] Cannot pause")
		return false
