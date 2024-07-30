extends Node

@export var player: PackedScene

#vars
var currentVolumePath: String
var currentWorld: Node2D
var mainScene: Node


#consts

#others 
enum volumes {
	volume1 = 1
}

func _ready() -> void:
	#get current volumes from saveManager later placeholder setup for now.
	currentVolumePath = volume_id_to_path(volumes.volume1)

func volume_id_to_path(id: volumes) -> String:
	match id:
		volumes.volume1:
			return "res://src/scenes/levels/volume1.tscn"
		_:
			return ""
