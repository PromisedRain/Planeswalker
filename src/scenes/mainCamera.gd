extends Node2D

var player = null
@onready var camera_2d = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = NodeUtility.get_player()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	camera_2d.position = player.position
