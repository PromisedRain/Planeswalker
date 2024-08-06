extends Node

@export var playerPath: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var cameraPath: PackedScene = preload("res://src/scenes/objects/mainCamera/mainCamera.tscn")

@onready var volumeContainer: Node2D

#vars
var mainScene: Node

var currentVolume: Node2D
var currentVolumePath: String

var currentSpawn
var currentRoom: Room
var currentRoomPath: String
var currentRoomPosition: Vector2

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
		free_volume_instance()
		var volumeInstance: Node2D = load(volumePath).instantiate()
		volumeContainer.add_child(volumeInstance)
		print("[levelManager] Changed volume to: %s" % volumePath)

func get_volume_path(volume: Volumes) -> String:
	match volume:
		Volumes.volume1:
			return volumePaths["volume1"]
		Volumes.volume2:
			return volumePaths["volume2"]
		_:
			return volumePaths["volume1"]

func free_volume_instance() -> void:
	if currentVolume != null:
		currentVolume.queue_free()
		currentVolume = null

func create_player_instance() -> CharacterBody2D: 
	var player: CharacterBody2D = playerPath.instantiate() 
	return player

func create_camera_instance() -> Camera2D:
	var camera: Camera2D = cameraPath.instantiate()
	return camera

