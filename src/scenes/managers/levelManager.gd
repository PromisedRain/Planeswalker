extends Node

@export var playerPath: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var playerCamera: PackedScene = preload("res://src/scenes/objects/playerCamera/playerCamera.tscn")

@onready var volumeContainer: Node2D

#vars
var mainScene: Node

var currentVolume: Volume 
var currentVolumePath: String
var currentVolumeName: String


var currentSpawn
var currentRoom: Room
var currentRoomPath: String
var currentRoomPosition: Vector2

#consts
const roomsPath: String = "res://src/scenes/levels/rooms/"

const fullVolumePaths: Dictionary = {
	"volume1": "res://src/scenes/levels/volume1.tscn",
	"volume2": "res://src/scenes/levels/volume2.tscn"
}

enum Volumes {
	volume1,
	volume2,
}

signal scenePathFailedLoad(scenePath: String)
signal scenePathInvalid(scenePath: String)
signal sceneStartedLoading(scene)


func _ready() -> void:
	SignalManager.chosenVolume.connect(change_volume)
	scenePathFailedLoad.connect(on_scene_path_failed_load)
	scenePathInvalid.connect(on_scene_path_invalid)
	sceneStartedLoading.connect(on_scene_started_loading)

func change_volume(volume: Volumes) -> void:
	change_current_volume(volume)

func change_current_volume(volume: Volumes) -> void:
	#var volumePath: String = get_volume_path(volume)
	var volumesPath: String = "res://src/scenes/levels/"
	var volumeName: String = get_volume_name(volume)
	
	if volumesPath == "":
		print("[levelManager] Invalid volume path at: %s" % volumesPath)
	else:
		free_volume_instance()
		print("[levelManager] Changed volume to: %s" % volumesPath)
		#var volumeInstance: Node2D = load(volumePath).instantiate()
		#volumeContainer.add_child(volumeInstance)

func get_volume_name(volume: Volumes) -> String:
	match volume:
		Volumes.volume1:
			return "volume1"
		Volumes.volume2:
			return "volume2"
		_:
			return "volume1"

func free_volume_instance() -> void:
	if currentVolume != null:
		currentVolume.queue_free()
		currentVolume = null

func create_player_instance() -> CharacterBody2D: 
	var player: CharacterBody2D = playerPath.instantiate() 
	return player

func create_camera_instance() -> Camera2D:
	var camera: Camera2D = playerCamera.instantiate()
	return camera

func load_room(roomName: String) -> void:
	load_scene(roomName, roomsPath)

func load_scene(sceneFilename: String, scenePath: String, monitorLoading: bool = false) -> void:
	sceneStartedLoading
	
	var dir: DirAccess = SaveManager.verify_and_open_dir(scenePath)
	

func monitor_loading() -> void:
	pass


func on_scene_path_failed_load() -> void:
	print("")

func on_scene_path_invalid() -> void:
	print("")

func on_scene_started_loading() -> void:
	print("")
