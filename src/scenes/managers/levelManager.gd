extends Node

@export var playerPath: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var playerCamera: PackedScene = preload("res://src/scenes/objects/playerCamera/playerCamera.tscn")

@onready var volumesParent: Node2D

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
var loadInProgress: bool = false
var loadQueue: Array[Node] = []

var sceneCache: Dictionary = {}
var sceneCacheOrder: Array[String] = []

#consts
const roomsPath: String = "res://src/scenes/levels/rooms"
const volumePath: String = "res://src/scenes/levels"

const maxSceneCacheSize: int = 10

enum Volumes {
	volume1,
	volume2,
}

signal filePathFailedLoad(filePath: String)
signal filePathInvalid(filePath: String)
signal fileStartedLoading(fileName: String)
signal fileFinishedLoading(file: Node, parent: Node, path: String)

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
	var volumeParent: Node2D = volumesParent
	
	if volumesPath == "":
		print("[levelManager] Invalid volume path at: %s" % volumesPath)
	else:
		free_volume_instance()
		load_volume(volumeName, volumesPath, volumeParent)

func free_volume_instance() -> void:
	if currentVolume != null:
		currentVolume.queue_free()
		currentVolume = null

#loading of scenes
func load_room(_roomName: String, _roomParent: Node) -> bool:
	if loadInProgress:
		push_warning("[levelManager] Loading in progress")
		return false
	
	load_scene(_roomName, roomsPath, _roomParent)
	return true

func load_volume(_volumeName: String, _volumePath: String, _volumeParent: Node) -> bool:
	if loadInProgress:
		push_warning("[levelManager] Loading in progress")
		return false
	
	load_scene(_volumeName, _volumePath, _volumeParent)
	return true

func cache_scene(filePath: String, scene: PackedScene) -> void:
	if sceneCache.size() >= maxSceneCacheSize:
		var oldest: String = sceneCacheOrder.pop_front()
		sceneCache.erase(oldest)
	
	sceneCache[filePath] = scene
	sceneCacheOrder.append(filePath)

func clear_scene_cache() -> void:
	sceneCache.clear()
	sceneCacheOrder.clear()
	print("[levelManager] Cleared scene cache")

func load_scene(fileName: String, filePath: String, fileParent: Node) -> void:
	fileStartedLoading.emit(fileName)
	var dir: DirAccess = SaveManager.verify_and_open_dir(filePath)
	
	var fullFilePath: String = "%s/%s.tscn" % [filePath, fileName]
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return
	
	var cachedScene: PackedScene = get_cached_scene(fullFilePath)
	if cachedScene:
		fileParent.add_child(cachedScene.instantiate())
		loadInProgress = false
		print("[levelManager] Loaded from cache: %s" % fullFilePath)
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
			print("[levelManager] thread in progress: %s%% " % progress) #TODO make it instantiate loadbar and shit in UiManager
		ResourceLoader.THREAD_LOAD_FAILED:
			filePathFailedLoad.emit(filePath)
			loadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			loadTimer.stop()
			loadTimer.queue_free()
			fileFinishedLoading.emit(ResourceLoader.load_threaded_get(filePath), fileParent, filePath)
			return

func on_file_finished_loading(incomingFile: PackedScene, fileParent: Node, filePath: String) -> void:
	print("[levelManager] Finished loading '%s'" % incomingFile.get_name().to_lower())
	#sceneCache[filePath] = incomingFile
	cache_scene(filePath, incomingFile)
	
	loadInProgress = false
	fileParent.add_child(incomingFile.instantiate())

func on_file_started_loading(fileName) -> void:
	print("[levelManager] Started loading '%s'" % fileName)
	
	loadInProgress = true

func on_file_path_failed_load(path: String) -> void:
	print("[levelManager] Failed to load '%s'" % path)

func on_file_path_invalid(path: String) -> void:
	print("[levelManager] Cannot open non-existent file at: %s" % path)

#getters
func get_player_instance() -> Player: 
	var player: Player = playerPath.instantiate() 
	return player

func get_player_camera_instance() -> Camera2D:
	var camera: Camera2D = playerCamera.instantiate()
	return camera

func get_volume_name(volume: Volumes) -> String:
	match volume:
		Volumes.volume1:
			return "volume1"
		Volumes.volume2:
			return "volume2"
		_:
			return "volume1"

func get_cached_scene(filePath: String) -> PackedScene:
	var cachedScene: Variant = sceneCache.get(filePath, null)
	if cachedScene is PackedScene:
		return cachedScene
	else:
		print("[levelManager] CachedScene not found or invalid: %s" % cachedScene)
		return null
	
	#if cachedScene != null:
	#	return cachedScene
	#else:
	#	return null
