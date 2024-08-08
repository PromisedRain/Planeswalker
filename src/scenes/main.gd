extends Node

@onready var animationPlayer: AnimationPlayer = $UILayer/AnimationPlayer

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var volume: Node2D = $Volume

#TODO remember to turn off on_top before shipping game cause its a problem, on top for debug only i guess guh

func _ready() -> void:
	SignalManager.initialLoadComplete.connect(initial_data_loaded)
	SaveManager.load_initial_data()

func initial_data_loaded(finishedProgress: bool) -> void: 
	if !finishedProgress:
		return
	
	LevelManager.mainScene = self
	LevelManager.volumesParent = volume
	
	#match LevelManager.currentVolume:
	#	"volume1":
	#		print("volume 1")
	#	_:
	#		print("volume ???")
	
	window.size_changed.connect(window_size_changed)
	UiManager.init()
	animationPlayer.play("black_to_clear")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug"):
		UiManager.open_debug_mode()
	if event.is_action_pressed("pause"):
		UiManager.open_pause_menu(true)

#int scaling on float
func window_size_changed() -> void: 
	print("size changed")
	var scale: Vector2i = window.size/windowBaseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)
