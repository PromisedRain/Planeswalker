extends Node

@export var playerPath: PackedScene = preload("res://src/scenes/objects/player/player.tscn")
@export var playerCamera: PackedScene = preload("res://src/scenes/objects/playerCamera/playerCamera.tscn")

@onready var volumesParent: Node2D

#vars
var mainScene: Node

var currentVolume: Volume 
var currentVolumeName: String
var currentVolumePath: String

var currentSpawn: Vector2
var currentRoom: Room
var currentRoomPath: String
var currentRoomGlobalPosition: Vector2

var sceneLoadTimer: Timer
var sceneLoadInProgress: bool = false
var sceneLoadQueue: Array[Dictionary] = []
var sceneCache: Dictionary = {}
var sceneCacheOrder: Array[String] = []

var useSubThreads: bool = true

var collectableDict: Dictionary = {}
var collectiblesCount: int = 0

const roomsPath: String = "res://src/scenes/volumes/rooms"
const volumePath: String = "res://src/scenes/volumes"

const maxSceneCacheSize: int = 10

enum Volumes {
	VOLUME_1,
	VOLUME_2,
}

enum SceneLoadProgress{
	LOADING,
	ADDED_TO_LOAD_QUEUE
}

signal filePathFailedLoad(filePath: String)
signal filePathInvalid(filePath: String)
signal fileStartedLoading(fileName: String)

signal loadNextSceneQueue

func _ready() -> void:
	SignalManager.chosenVolume.connect(change_volume) # from volumeSelection
	
	filePathFailedLoad.connect(on_file_path_failed_load)
	filePathInvalid.connect(on_file_path_invalid)
	fileStartedLoading.connect(on_file_started_loading)
	loadNextSceneQueue.connect(on_load_next_scene_queue)
	
	if !sceneLoadInProgress && sceneLoadQueue.size() > 0:
		on_load_next_scene_queue()

func init(_mainScene: Node, _volumesParent: Node2D) -> void:
	mainScene = _mainScene
	volumesParent = _volumesParent

func change_volume(volume: Volumes) -> void:
	change_current_volume(volume)

func change_current_volume(volume: Volumes) -> void:
	var volumeName: String = get_volume_name(volume)
	
	if volumePath == "":
		Utils.debug_print(self, "invalid volume path at: %s", [volumePath])
	elif volumeName == "":
		Utils.debug_print(self, "invalid volume name at: %s", [volumeName])
	else:
		free_volume_instance()
		var progress: SceneLoadProgress = load_volume(volumeName, Callable(self, "on_volume_load"))
		
		match progress:
			SceneLoadProgress.LOADING:
				Utils.debug_print(self, "loading")
			SceneLoadProgress.ADDED_TO_LOAD_QUEUE:
				Utils.debug_print(self, "added '%s' to scene load queue", [volumeName])

func on_volume_load(loadedScene: PackedScene, _sceneName: String) -> void:
	if !loadedScene is PackedScene:
		print("failed to load scene?")
		return
	
	var instance = loadedScene.instantiate()
	volumesParent.add_child(instance)
	Utils.debug_print(self, "successfully added volume '%s'", [instance.get_name()])

func free_volume_instance() -> void:
	if currentVolume != null:
		currentVolume.queue_free()
		currentVolume = null

func load_room(_roomName: String, callback: Callable) -> SceneLoadProgress:
	if sceneLoadInProgress:
		load_scene_async(_roomName, roomsPath, callback)
		return SceneLoadProgress.ADDED_TO_LOAD_QUEUE
	
	load_scene_async(_roomName, roomsPath, callback)
	return SceneLoadProgress.LOADING

func load_volume(volumeName: String, callback: Callable) -> SceneLoadProgress:
	if sceneLoadInProgress:
		load_scene_async(volumeName, volumePath, callback)
		return SceneLoadProgress.ADDED_TO_LOAD_QUEUE
	
	load_scene_async(volumeName, volumePath, callback)
	return SceneLoadProgress.LOADING

func add_to_scene_load_queue(fileName: String, filePath: String, callback: Callable = Callable()) -> void: #fileParent: Node, callback: Callable = Callable()) -> void:
	var sceneInfo: Dictionary = {
		"file_name": fileName,
		"file_path": filePath,
		#"file_parent": fileParent,
		"file_callback": callback
	}
	sceneLoadQueue.append(sceneInfo)

func on_load_next_scene_queue() -> void:
	if sceneLoadQueue.size() == 0:
		return
	
	var sceneInfo: Dictionary = sceneLoadQueue.pop_front()
	var fileName: String = sceneInfo["file_name"]
	var filePath: String = sceneInfo["file_path"]
	var fileCallback: Callable = sceneInfo["file_callback"]
	load_scene_async(fileName, filePath, fileCallback)

func cache_scene(filePath: String, scene: PackedScene) -> void:
	if sceneCache.size() >= maxSceneCacheSize:
		var oldest: String = sceneCacheOrder.pop_front()
		sceneCache.erase(oldest)
	
	sceneCache[filePath] = scene
	sceneCacheOrder.append(filePath)

func clear_scene_cache() -> void:
	sceneCache.clear()
	sceneCacheOrder.clear()
	Utils.debug_print(self, "cleared scene cache")

func reset_scene_loading_state() -> void:
	clear_scene_cache()
	
	if sceneLoadTimer != null:
		sceneLoadTimer.queue_free()
	
	if sceneLoadInProgress:
		sceneLoadInProgress = false
		sceneLoadQueue.clear()
	else:
		sceneLoadQueue.clear()
	Utils.debug_print(self, "reset scene loading state")

func load_scene_async(fileName: String, filePath: String, callback: Callable) -> void: #fileParent: Node, callback: Callable) -> void:
	if sceneLoadInProgress:
		Utils.debug_print(self, "load currently in progress, adding '%s' to the queue, queue size: %s", [fileName, sceneLoadQueue.size()])
		add_to_scene_load_queue(fileName, filePath, callback)
		return 
	
	fileStartedLoading.emit(fileName)
	var dir: DirAccess = SaveManager.verify_and_open_dir(filePath)
	
	if !dir:
		return
	
	var fullFilePath: String = "%s/%s.tscn" % [filePath, fileName]
	
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return 
	
	var cachedScene: PackedScene = get_cached_scene(fullFilePath)
	
	if cachedScene != null:
		Utils.debug_print(self, "loaded '%s' from cache", [fullFilePath])
		if callback && callback.is_valid():
			callback.call(cachedScene, fileName)
		#fileParent.add_child(cachedScene.instantiate())
		sceneLoadInProgress = false
		loadNextSceneQueue.emit()
		return
	
	var loader = ResourceLoader.load_threaded_request(fullFilePath, "", useSubThreads)
	
	if !ResourceLoader.exists(fullFilePath) || loader == null:
		filePathInvalid.emit(fullFilePath)
		return
	
	sceneLoadTimer = Timer.new()
	sceneLoadTimer.wait_time = 0.1
	sceneLoadTimer.timeout.connect(monitor_scene_load_progress.bind(fileName, fullFilePath, callback))
	get_tree().root.add_child(sceneLoadTimer)
	sceneLoadTimer.start()

func monitor_scene_load_progress(fileName: String, fullFilePath: String, callback: Callable) -> void: #fileParent: Node, callback: Callable) -> void:
	var progress: Array = []
	var loadStatus = ResourceLoader.load_threaded_get_status(fullFilePath, progress)
	
	match loadStatus:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			filePathInvalid.emit(fullFilePath)
			sceneLoadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			Utils.debug_print(self, "thread in progress: %s%%", [str(progress)]) #TODO make it instantiate loadbar and shit in UiManager
		ResourceLoader.THREAD_LOAD_FAILED:
			filePathFailedLoad.emit(fullFilePath)
			sceneLoadTimer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			sceneLoadTimer.stop()
			sceneLoadTimer.queue_free()
			var loadedScene = ResourceLoader.load_threaded_get(fullFilePath)
			
			if loadedScene is PackedScene:
				cache_scene(fullFilePath, loadedScene)
				if callback && callback.is_valid():
					callback.call(loadedScene, fileName)
			else:
				filePathFailedLoad.emit(fullFilePath)
			
			sceneLoadInProgress = false
			loadNextSceneQueue.emit()
			return

func on_file_started_loading(fileName) -> void:
	Utils.debug_print(self, "started loading '%s'", [fileName])
	sceneLoadInProgress = true

func on_file_path_failed_load(path: String) -> void:
	Utils.debug_print(self, "failed to load '%s'", [path])
	sceneLoadInProgress = false

func on_file_path_invalid(path: String) -> void:
	Utils.debug_print(self, "cannot open non-existent file at: %s", [path])
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
		Volumes.VOLUME_1:
			return "volume1"
		Volumes.VOLUME_2:
			return "volume2"
		_:
			return "volume1"

func get_cached_scene(filePath: String) -> PackedScene:
	var cachedScene: Variant = sceneCache.get(filePath, null)
	if cachedScene is PackedScene:
		return cachedScene
	else:
		Utils.debug_print(self, "cached scene not found or invalid: %s", [cachedScene])
		return null
