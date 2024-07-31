extends Node

@onready var player: CharacterBody2D = Utils.get_player()
@onready var animationPlayer: AnimationPlayer = $HUD/AnimationPlayer

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var hud: CanvasLayer = $HUD

@onready var volume: Node2D = $Volume


func _ready() -> void: 
	SaveManager.load_before_game_data()
	SaveManager.save_config_file() #TODO add this someone in each settings function so it saves when you change settings.
	var world: Node2D = load(LevelManager.currentVolumePath).instantiate()
	LevelManager.currentWorld = world
	volume.add_child(world)
	LevelManager.mainScene = self
	
	#match LevelManager.currentWorld:
	#	"volume1":
	#		print("ttttypee shii")
	
	print("[main] Screen size: %s" % windowScreenSize)
	window.size_changed.connect(window_size_changed)
	hud.init_hud()
	animationPlayer.play("dip_to_clear")

func _unhandled_input(event) -> void:
	if event.is_action_pressed("debug"):
		hud.open_debug_mode()
	if event.is_action_pressed("pause"):
		hud.open_pause_menu()

# integer scaling on fractional
func window_size_changed() -> void: 
	var scale: Vector2i = window.size/windowBaseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

#getters
var canControl: bool:
	get:
		return true
