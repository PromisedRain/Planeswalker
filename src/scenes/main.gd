extends Node

@onready var player: CharacterBody2D = NodeUtility.get_player()

@onready var window: Window = get_window() 
@onready var windowBaseSize: Vector2i = window.content_scale_size
@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size

@onready var debugManager: CanvasLayer = $DebugManager

#vars
var inDebug: bool = false

#constants

func _ready() -> void: 
	print("screen size: %s" %windowScreenSize)
	window.size_changed.connect(window_size_changed) 

# integer
func window_size_changed() -> void: 
	var scale: Vector2i = window.size/windowBaseSize 
	window.content_scale_size = window.size / (scale.y if scale.y <= scale.x else scale.x)

func _process(delta: float) -> void:
	update(delta)
	if canControl:
		global_inputs()

func update(delta: float) -> void:
	pass

func global_inputs() -> void:
	if Input.is_action_just_pressed("debug"):
		handle_debug_visibility()

func handle_debug_visibility() -> void:
	#var debugTrail: Line2D = player.get_node("DebugTrail")
	if !inDebug:
		print("[console] debug is on")
		inDebug = true
	#	debugManager.visible = true
	#	debugTrail.visible = true
	else:
		print("[console] debug is off")
		inDebug = false
	#	debugManager.visible = false
	#	debugTrail.visible = false

#getters
var canControl: bool:
	get:
		return true
