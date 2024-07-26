extends Node

@onready var player: CharacterBody2D = NodeUtility.get_player()

@onready var window: Window = get_window() 
@onready var baseSize: Vector2i = window.content_scale_size
@onready var screenSize: Vector2i = get_viewport().get_visible_rect().size

#managers
@onready var debugManager = $DebugManager

#vars
var inDebug: bool = false

#constants

func _ready() -> void: 
	print("screen size: %s" %screenSize)
	
	
	window.size_changed.connect(window_size_changed) 

# integer
func window_size_changed() -> void: 
	var scale: Vector2i = window.size/baseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

func _process(delta: float) -> void:
	update(delta)
	player_inputs()

func update(delta: float) -> void:
	pass

func player_inputs() -> void:
	if Input.is_action_just_pressed("debug"):
		handle_debug_visibility()

func handle_debug_visibility() -> void:
	#var debugTrail: Line2D = player.get_node("DebugTrail")
	if !inDebug:
		print("[console] debug is on")
		inDebug = true
		debugManager.visible = true
	#	debugTrail.visible = true
	else:
		print("[console] debug is off")
		inDebug = false
		debugManager.visible = false
	#	debugTrail.visible = false
