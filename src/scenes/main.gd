extends Node

@onready var animationPlayer: AnimationPlayer = $UILayer/AnimationPlayer
@onready var colorRect: ColorRect = $UILayer/ColorRect

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var world: Node2D = $SubViewport/World

#TODO remember to turn off on_top before shipping game cause its a problem, on top for debug only i guess guh

func _ready() -> void:
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	window.size_changed.connect(window_size_changed)
	
	SignalManager.initialLoadComplete.connect(init)
	SaveManager.load_initial_data()

func init(dataLoaded: bool) -> void: 
	if !dataLoaded:
		return
	
	LevelManager.mainScene = self
	LevelManager.volumesParent = world
	UiManager.init()
	
	#match LevelManager.currentVolume:
	#	"volume1":
	#		print("volume 1")
	#	_:
	#		print("volume ???")
	
	if !colorRect.visible:
		colorRect.visible = true
	animationPlayer.play("black_to_clear")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug"):
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

func window_size_changed() -> void: 
	pass
	#print("size changed")
	#var scale: Vector2i = window.size / windowBaseSize 
	#window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)
