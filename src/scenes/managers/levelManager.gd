extends Node

@export var player: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var mainCamera: PackedScene = preload("res://src/scenes/objects/mainCamera/mainCamera.tscn")

@onready var worldContainer: Node2D

#vars
var mainScene: Node

var currentVolumePath: String
var currentWorld: Node2D

var currentSpawn
var currentRoomName
var currentRoom: Room


#consts
const volumePaths: Dictionary = {
	"volume1": "res://src/scenes/levels/volume1.tscn",
	"volume2": "res://src/scenes/levels/volume2.tscn"
}

enum Volumes {
	volume1,
	volume2,
	volume3
}

func _ready() -> void:
	pass
	#currentVolumePath = volumePaths.get("volume1", null)

func change_current_volume(volume: Volumes) -> void:
	var volumePath: String = get_volume_path(volume)
	if !volumePath != "":
		print("[levelManager] Invalid volume path for at: %s" % volumePath)
	else:
		free_world_instance()
		var instance: Node2D = load(volumePath).instantiate()
		worldContainer.add_child(instance)
		print("[levelManager] Changed volume to: %s" % volumePath)

func get_volume_path(volume: Volumes) -> String:
	match volume:
		Volumes.volume1:
			return volumePaths["volume1"]
		Volumes.volume2:
			return volumePaths["volume2"]
		_:
			return volumePaths["volume1"]

func free_world_instance() -> void:
	if currentWorld != null:
		currentWorld.queue_free()
		currentWorld = null

