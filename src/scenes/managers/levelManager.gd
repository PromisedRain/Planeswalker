extends Node

@export var playerPath: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var playerCamera: PackedScene = preload("res://src/scenes/objects/playerCamera/playerCamera.tscn")

@onready var volumesParent: Node2D

#vars
var mainScene: Node

var currentVolume: VolumeComponent 
var currentVolumePath: String
var currentVolumeName: String

var currentSpawn
var currentRoom: RoomComponent
var currentRoomPath: String
var currentRoomPosition: Vector2

var sceneLoadTimer: Timer
var sceneLoadInProgress: bool = false
var sceneLoadQueue: Array[Dictionary] = []
var sceneCache: Dictionary = {}
var sceneCacheOrder: Array[String] = []

var collectableDict: Array = []
var collectiblesCount: int = 0

#consts
const roomsPath: String = "res://src/scenes/volumes/rooms"
const volumePath: String = "res://src/scenes/volumes"

const maxSceneCacheSize: int = 10

enum Volumes {
	volume1,
	volume2,
}

signal filePathFailedLoad(filePath: String)
signal filePathInvalid(filePath: String)
signal fileStartedLoading(fileName: String)
signal fileFinishedLoading(file: Node, parent: Node, path: String)

signal loadNextSceneQueue

func _ready() -> void:
	SignalManager.chosenVolume.connect(change_volume) # from volumeSelection
	
	filePathFailedLoad.connect(on_file_path_failed_load)
	filePathInvalid.connect(on_file_path_invalid)
	fileStartedLoading.connect(on_file_started_loading)
	fileFinishedLoading.connect(on_file_finished_loading)
	loadNextSceneQueue.connect(on_load_next_scene_queue)
	
	if !sceneLoadInProgress && sceneLoadQueue.size() > 0:
		on_load_next_scene_queue()

func init(_mainScene: Node, _volumesParent: Node2D) -> void:
	mainScene = _mainScene
	volumesParent = _volumesParent

func change_volume(volume: Volumes) -> void:
	change_current_volume(volume)

func change_current_volume(volume: Volumes) -> void:
	var volumesPath: String = volumePath
	var volumeName: String = get_volume_name(volume)
	var volumeParent: Node2D = volumesParent
	
	if volumesPath == "":
		print("[levelManager] Invalid volume path at: %s" % volumesPath)
	else:
		free_volume_instance()
		#var main = Utils.get_main()
		#main.get_node("UiLayer/VersionLabel") #TODO make it hide the versionlabel when you arent in main menu
		load_volume(volumeName, volumesPath, volumeParent)

func free_volume_instance() -> void:
	if currentVolume != null:
		currentVolume.queue_free()
		currentVolume = null

func load_room(_roomName: String, _roomParent: Node) -> bool:
	#if sceneLoadInProgress:
	#	load_scene(_roomName, roomsPath, _roomParent)
	#	return false
	load_scene(_roomName, roomsPath, _roomParent)
	return true

func load_volume(_volumeName: String, _volumePath: String, _volumeParent: Node) -> bool:
	#if sceneLoadInProgress:
	#	load_scene(_volumeName, _volumePath, _volumeParent)
	#	return false
	load_scene(_volumeName, _volumePath, _volumeParent)
	return true

func add_to_scene_load_queue(fileName: String, filePath: String, fileParent: Node) -> void:
	var sceneInfo: Dictionary = {
		"file_name": fileName,
		"file_path": filePath,
		"file_parent": fileParent
	}
	sceneLoadQueue.append(sceneInfo)

func on_load_next_scene_queue() -> void:
	if sceneLoadQueue.size() == 0:
		return
	
	var nextSceneInfo: Dictionary = sceneLoadQueue.pop_front()
	var fileName: String = nextSceneInfo["file_name"]
	var filePath: String = nextSceneInfo["file_path"]
	var fileParent: Node = nextSceneInfo["file_parent"]
	load_scene(fileName, filePath, fileParent)

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

func reset_scene_loading_state() -> void:
	clear_scene_cache()
	
	if sceneLoadTimer != null:
		sceneLoadTimer.queue_free()
	
	if sceneLoadInProgress:
		sceneLoadInProgress = false
		sceneLoadQueue.clear()
	else:
		sceneLoadQueue.clear()
	
	print("[levelManager] Reset scene loading state")

func load_scene(fileName: String, filePath: String, fileParent: Node) -> void:
	if sceneLoadInProgress:
		print("[levelManager] Load currently in progress, adding '%s' to queue" % fileName)
		add_to_scene_load_queue(fileName, filePath, fileParent)
		#sceneLoadInProgress = false
		return 
	
	#print("fileParent Type: ", typeof(fileParent))
	
	fileStartedLoading.emit(fileName)
	var dir: DirAccess = SaveManager.verify_and_open_dir(filePath)
	
	var fullFilePath: String = "%s/%s.tscn" % [filePath, fileName]
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return 
	
	var cachedScene: PackedScene = get_cached_scene(fullFilePath)
	if cachedScene != null:
		print("[levelManager] Loaded from cache: %s" % fullFilePath)
		fileParent.add_child(cachedScene.instantiate())
		sceneLoadInProgress = false #TODO eventually have sceneLoadInProgress = false sets at the penultimate line before return. implement sceneQueueing for this
		return
	
	var loader = ResourceLoader.load_threaded_request(fullFilePath)
	if !ResourceLoader.exists(fullFilePath) || loader == null:
		filePathInvalid.emit(fullFilePath)
		return
	
	sceneLoadTimer = Timer.new()
	sceneLoadTimer.wait_time = 0.1
	sceneLoadTimer.timeout.connect(monitor_scene_load_progress.bind(fullFilePath, fileParent))
	
	get_tree().root.add_child(sceneLoadTimer)
	sceneLoadTimer.start()

func monitor_scene_load_progress(filePath: String, fileParent: Node) -> void:
	var progress: Array = []
	var loadStatus = ResourceLoader.load_threaded_get_status(filePath, progress)
	
	match loadStatus:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			filePathInvalid.emit(filePath)
			sceneLoadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print("[levelManager] thread in progress: %s%% " % str(progress)) #TODO make it instantiate loadbar and shit in UiManager
		ResourceLoader.THREAD_LOAD_FAILED:
			filePathFailedLoad.emit(filePath)
			sceneLoadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			sceneLoadTimer.stop()
			sceneLoadTimer.queue_free()
			fileFinishedLoading.emit(ResourceLoader.load_threaded_get(filePath), fileParent, filePath)
			return

func on_file_finished_loading(incomingFile: PackedScene, fileParent: Node, filePath: String) -> void:
	print("[levelManager] Finished loading '%s'" % filePath)
	cache_scene(filePath, incomingFile)
	
	fileParent.add_child(incomingFile.instantiate())
	sceneLoadInProgress = false
	loadNextSceneQueue.emit()

func on_file_started_loading(fileName) -> void:
	print("[levelManager] Started loading '%s'" % fileName)
	sceneLoadInProgress = true

func on_file_path_failed_load(path: String) -> void:
	printerr("[levelManager] Failed to load '%s'" % path)
	sceneLoadInProgress = false

func on_file_path_invalid(path: String) -> void:
	printerr("[levelManager] Cannot open non-existent file at: %s" % path)
	sceneLoadInProgress = false

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
