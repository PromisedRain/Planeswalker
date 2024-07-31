extends Node

@export var player: PackedScene

#vars
var currentVolumePath: String
var currentWorld: Node2D
var mainScene: Node

#consts
const volumes: Dictionary = {
	"volume1": Volumes.volume1
}

#others
enum Volumes {
	volume1
}

func _ready() -> void:
	#get current volumes from saveManager later placeholder setup for now.
	currentVolumePath = volume_to_path(volumes["volume1"])

func volume_to_path(volume: Volumes) -> String:
	match volume:
		volumes.volume1:
			return "res://src/scenes/levels/volume1.tscn"
		_:
			return ""
