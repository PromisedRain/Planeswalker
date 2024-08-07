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

var loadTimer: Timer
var loadFileParent: Node
var loadInProgress: bool = false

#consts
const roomsPath: String = "res://src/scenes/levels/rooms/"
const volumePath: String = "res://src/scenes/levels"

const fullVolumePaths: Dictionary = {
	"volume1": "res://src/scenes/levels/volume1.tscn",
	"volume2": "res://src/scenes/levels/volume2.tscn"
}

enum Volumes {
	volume1,
	volume2,
}

signal filePathFailedLoad(filePath: String)
signal filePathInvalid(filePath: String)
signal fileStartedLoading(fileName: String)
signal fileFinishedLoading(file: Node, parent: Node)

func _ready() -> void:
	SignalManager.chosenVolume.connect(change_volume) # from volumeSelection
	
	filePathFailedLoad.connect(on_file_path_failed_load)
	filePathInvalid.connect(on_file_path_invalid)
	fileStartedLoading.connect(on_file_started_loading)
	fileFinishedLoading.connect(on_file_finished_loading)

func change_volume(volume: Volumes) -> void:
	change_current_volume(volume)

func change_current_volume(volume: Volumes) -> void:
	#var volumePath: String = get_volume_path(volume)
	var volumesPath: String = volumePath
	var volumeName: String = get_volume_name(volume)
	var volumeParent: Node2D = volumeContainer
	
	if volumesPath == "":
		print("[levelManager] Invalid volume path at: %s" % volumesPath)
	else:
		free_volume_instance()
		load_volume(volumeName, volumesPath, volumeParent)
		#volumeContainer.add_child(volumeInstance
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

func get_player_instance() -> Player: 
	var player: Player = playerPath.instantiate() 
	return player

func get_player_camera_instance() -> Camera2D:
	var camera: Camera2D = playerCamera.instantiate()
	return camera

func load_room(_roomName: String, _roomParent: Node) -> void:
	if loadInProgress:
		print("[levelManager] Loading in progress")
		push_warning("[levelManager] Loading in progress")
		return
	
	load_scene(_roomName, roomsPath, _roomParent)

func load_volume(_volumeName: String, _volumePath: String, _volumeParent: Node) -> void:
	if loadInProgress:
		print("[levelManager] Loading in progress")
		push_warning("[levelManager] Loading in progress")
		return
	
	load_scene(_volumeName, _volumePath, _volumeParent)

func load_scene(fileName: String, filePath: String, fileParent: Node) -> void:
	fileStartedLoading.emit(fileName)
	var dir: DirAccess = SaveManager.verify_and_open_dir(filePath)
	
	var fullFilePath: String = "%s/%s.tscn" % [filePath, fileName]
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return
	
	var loader = ResourceLoader.load_threaded_request(fullFilePath)
	if !ResourceLoader.exists(fullFilePath) || loader == null:
		filePathInvalid.emit(fullFilePath)
		return
	
	loadTimer = Timer.new()
	loadTimer.wait_time = 0.1
	loadTimer.timeout.connect(monitor_load_progress.bind(fullFilePath, fileParent))
	
	get_tree().root.add_child(loadTimer)
	loadTimer.start()

func monitor_load_progress(filePath: String, fileParent: Node) -> void:
	var progress: Array = []
	var loadStatus = ResourceLoader.load_threaded_get_status(filePath, progress)
	
	match loadStatus:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			filePathInvalid.emit(filePath)
			loadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("[levelManager] thread in progress: %s% " % progress) #TODO make it instantiate loadbar and shit in UiManager
		ResourceLoader.THREAD_LOAD_FAILED:
			filePathFailedLoad.emit(filePath)
			loadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			loadTimer.stop()
			loadTimer.queue_free()
			fileFinishedLoading.emit(ResourceLoader.load_threaded_get(filePath).instantiate(), fileParent)
			return

func on_file_finished_loading(loadedFile: Node, fileParent: Node) -> void:
	print("[levelManager] Finished loading '%s'" % loadedFile.get_name().to_lower())
	
	loadInProgress = false
	fileParent.add_child(loadedFile)

func on_file_started_loading(fileName) -> void:
	print("[levelManager] Started loading '%s'" % fileName)
	
	loadInProgress = true

func on_file_path_failed_load(path: String) -> void:
	print("[levelManager] Failed to load '%s'" % path)

func on_file_path_invalid(path: String) -> void:
	print("[levelManager] Cannot open non-existent file at: %s" % path)
