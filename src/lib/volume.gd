class_name Volume
extends Node2D

@export_category("volume specific")
@export var rooms: Node2D
@export var objects: Node2D
@export var worldEnvironment: WorldEnvironment 
@export var canvasModulate: CanvasModulate
@export var volumeSpawn: Marker2D
@export var volumeDebugSpawn: Marker2D

@export_category("volume info")
@export var volumeGivenName: String
@export_range(Utils.minVolumesCurrently, Utils.maxVolumesCurrently) var volumeID: int
@export var spawnDebug: bool

var roomGlobalPositions: Dictionary = {}
var roomGlobalBounds: Dictionary = {}
var roomInstances: Dictionary = {}

var volumeRoomInfo: Dictionary = {}

var loadedAdjacentRooms: Dictionary = {}

var volumesDirPath: String = "user://volumes"

const roomAdjacencyThreshold: float = 20.0
#const playerSpawnPositionYGrace: int = 6

var currentRoom: Room
var currentCamera: MainCamera
var currentPlayer: Player

signal instanceInvalid(instance: Node2D)

func _ready() -> void:
	instanceInvalid.connect(on_instance_invalid)
	
	if is_instance_valid(worldEnvironment):
		pass
	else:
		instanceInvalid.emit(worldEnvironment)
	
	if is_instance_valid(canvasModulate):
		pass
	else:
		instanceInvalid.emit(canvasModulate)
	
	update_current_volume()
	
	#save_room_bounds_and_pos()
	save_room_instances()
	
	if !SaveManager.fileBuildManager.get_volumes_meta_data_file_exists():
		SaveManager.fileBuildManager.save_room_data_to_json(volumeID, rooms)
		Utils.debug_print(self, "no volumes metadata file exists, made one")
	
	volumeRoomInfo.clear()
	volumeRoomInfo = SaveManager.fileBuildManager.get_volume_room_data(volumeID)
	
	free_all_rooms()
	load_current_room()
	load_current_spawn()
	
	get_volume_info()
	
	SaveManager.save_game()

func load_current_room() -> void:
	var saveRoomName: String = SaveManager.get_slot_data("current_room")
	var progress: LevelManager.SceneLoadProgress
	
	if saveRoomName == null || saveRoomName == "":
		Utils.debug_print(self, "no saved room found, loading default")
		var defaultFirstRoomName: String = get_first_room()
		
		progress = LevelManager.load_room(defaultFirstRoomName, Callable(self, "on_room_load").bind(true))
		handle_room_load_progress(progress)
		return
	
	progress = LevelManager.load_room(saveRoomName, Callable(self, "on_room_load").bind(true))
	handle_room_load_progress(progress)

func load_current_spawn() -> void:
	var saveSpawnGlobalPosition: Vector2 = Vector2(
		SaveManager.get_slot_data("current_spawn_global_position_x"),
		SaveManager.get_slot_data("current_spawn_global_position_y")
	)
	var playerInstance: Player = LevelManager.get_player_instance()
	
	if spawnDebug:
		Utils.debug_print(self, "spawn: debug spawn")
		var debugSpawnGlobalPosition: Vector2 = volumeDebugSpawn.global_position
		add_player_instance(playerInstance, debugSpawnGlobalPosition)
		add_camera_instance()
		return
	
	if saveSpawnGlobalPosition == Vector2.ZERO:
		Utils.debug_print(self, "spawn: default spawn")
		var defaultSpawnGlobalPosition: Vector2 = volumeSpawn.global_position
		add_player_instance(playerInstance, defaultSpawnGlobalPosition)
		add_camera_instance()
		return
	
	Utils.debug_print(self, "spawn: save spawn")
	add_player_instance(playerInstance, saveSpawnGlobalPosition) #+ Vector2(0, -20.0).round())
	add_camera_instance()

func add_player_instance(_player: Player, _pos: Vector2) -> void:
	#var modifiedPosTest: Vector2 = Vector2(_pos.x, _pos.y + (playerSpawnPositionYGrace) * -1)
	
	currentPlayer = _player
	_player.global_position = _pos.round()
	objects.add_child(_player)

func add_camera_instance() -> void:
	var cameraInstance: MainCamera = CameraManager.get_main_camera_instance()
	
	if currentCamera == null:
		currentCamera = cameraInstance
		CameraManager.set_current_camera(cameraInstance)
		cameraInstance.reset_initial_position(currentPlayer)
		objects.add_child(cameraInstance)

func handle_room_load_progress(progress: LevelManager.SceneLoadProgress) -> void:
	match progress:
		LevelManager.SceneLoadProgress.LOADING:
			pass
			#Utils.debug_print(self, "loading ")
		LevelManager.SceneLoadProgress.ADDED_TO_LOAD_QUEUE:
			pass

func on_room_load(loadedScene: PackedScene, roomName: String, updateRoom: bool = false) -> void:
	if !loadedScene is PackedScene:
		Utils.debug_print(self, "failed to load scene '%s'", [loadedScene])
		return
	
	var roomInstance: Room = loadedScene.instantiate()
	
	
	var roomGlobalPosition: Vector2 = get_room_global_position(roomName) #roomGlobalPositions[roomName]
	
	roomInstance.global_position = roomGlobalPosition
	roomInstance.room_entered.connect(on_room_entered)
	
	rooms.add_child(roomInstance)
	
	if updateRoom:
		handle_room(roomInstance)

func update_current_volume() -> void:
	Utils.debug_print(self, "updating current volume to: %s" % self.get_name())
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumeName = self.get_name()
	
	var slot: int = SaveManager.currentSaveSlot
	var latestVolumeID: int = int(SaveManager.get_slot_data("current_volume"))
	
	if !volumeID > latestVolumeID:
		Utils.debug_print(self, "current volume ID not higher than saved, no update required")
	else:
		Utils.debug_print(self, "new volume reached")
		
		SaveManager.set_specific_slot_meta_data(slot, "current_volume", volumeID)
		SaveManager.set_specific_slot_meta_data(slot, "latest_volume_name", volumeGivenName)
		SaveManager.save_current_meta_data()
		
		SaveManager.set_slot_data("current_volume", volumeID)
		SaveManager.save_slot(slot, SaveManager.currentSlotData)

func update_current_room(room: Room) -> void:
	var prevRoom: Room = room
	
	if prevRoom != null || is_instance_valid(prevRoom):
		prevRoom.change_children_processes(false)
	else:
		instanceInvalid.emit(prevRoom)
	
	currentRoom = room
	currentRoom.change_children_processes(true)
	
	loadedAdjacentRooms[room.roomName] = true
	
	LevelManager.currentRoom = room
	LevelManager.currentRoomName = room.roomName
	
	SaveManager.set_slot_data("current_room", room.roomName)

func on_room_entered(room: Room, checkpoint: RoomCheckpoint) -> void:
	handle_room(room, checkpoint)

func player_died() -> void:
	Utils.debug_print(self, "player died")
	
	reload_room()
	reload_camera()
	
	currentPlayer.global_position = LevelManager.currentSpawn.round() + Vector2(0, -1)

func free_all_rooms() -> void:
	for room: Room in rooms.get_children():
		if room != null || is_instance_valid(room):
			room.queue_free()
		else:
			instanceInvalid.emit(room)

#func save_room_bounds_and_pos() -> void:
#	roomGlobalPositions.clear()
#	roomGlobalBounds.clear()
#	
#	for room: Room in rooms.get_children():
#		if room != null || is_instance_valid(room):
#			roomGlobalPositions[room.roomName] = room.global_position
#			roomGlobalBounds[room.roomName] = room.get_global_room_bounds()
#		else:
#			instanceInvalid.emit(room)

func save_room_instances() -> void:
	roomInstances.clear()
	
	for room: Room in rooms.get_children():
		if room != null || is_instance_valid(room):
			roomInstances[room.roomName] = room
		else:
			instanceInvalid.emit(room)

func handle_room(room: Room, checkpoint: Variant = null) -> void:
	var roomBounds: Dictionary = room.get_camera_bounds()
	#CameraManager.set_active_camera_bounds(roomBounds)
	
	if checkpoint is RoomCheckpoint:
		save_player_global_pos(checkpoint.get_spawn_position())
	else:
		save_player_global_pos()
	
	if room != currentRoom || currentRoom == null:
		#print("processing new room")
		update_current_room(room)
		
		var _rooms: Dictionary = get_non_and_adjacent_rooms()
		free_non_adjacent_rooms(_rooms["non_adjacent_rooms"])
		load_adjacent_rooms(_rooms["adjacent_rooms"])

func free_non_adjacent_rooms(_rooms: Array[String]) -> void:
	for roomName: String in _rooms:
		var roomInstance = roomInstances[roomName]
		
		if roomInstance != null:
			roomInstance.queue_free()
			loadedAdjacentRooms.erase(roomName)

func load_adjacent_rooms(_rooms: Array[String]) -> void:
	var progress: LevelManager.SceneLoadProgress
	
	for roomName: String in _rooms:
		if loadedAdjacentRooms.has(roomName):
			continue
		
		progress = LevelManager.load_room(roomName, Callable(self, "on_room_load"))
		handle_room_load_progress(progress)
		
		loadedAdjacentRooms[roomName] = true

func get_non_and_adjacent_rooms() -> Dictionary: 
	var adjacentRooms: Array[String] = []
	var nonAdjacentRooms: Array[String] = []
	var bothArrays: Dictionary = {}
	var currentBounds: Rect2 = get_room_bounds(currentRoom.roomName) #currentRoom.get_global_room_bounds()
	
	for roomName in roomGlobalBounds.keys():
		if roomName == currentRoom.roomName:
			continue
		
		var bounds: Rect2 = roomGlobalBounds[roomName]
		
		if are_rooms_adjacent(currentBounds, bounds):
			adjacentRooms.append(roomName)
		else:
			nonAdjacentRooms.append(roomName)
	
	bothArrays["adjacent_rooms"] = adjacentRooms
	bothArrays["non_adjacent_rooms"] = nonAdjacentRooms
	
	#print("current room: %s" % currentRoom.roomName)
	#print(bothArrays)
	return bothArrays

func are_rooms_adjacent(bounds1: Rect2, bounds2: Rect2) -> bool:
	var expandedBounds1: Rect2 = Rect2(bounds1.position - Vector2(roomAdjacencyThreshold, roomAdjacencyThreshold),
	bounds1.size + Vector2(roomAdjacencyThreshold * 2, roomAdjacencyThreshold * 2))
	return expandedBounds1.intersects(bounds2)

func reload_room() -> void:
	print("reloading room")
	
	#var roomName: String = str(LevelManager.currentRoomName)
	#var roomInstance: Room = load(roomPath).instantiate()
	#var oldRoom: Room = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = CameraManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

func save_player_global_pos(checkpointPos: Variant = null) -> void:
	if checkpointPos != null && checkpointPos is Vector2:
		checkpointPos = checkpointPos as Vector2
		SaveManager.set_slot_data("current_spawn_global_position_x", checkpointPos.x)
		SaveManager.set_slot_data("current_spawn_global_position_y", checkpointPos.y + -1)
		print("checkpoint position spawn")
	else:
		SaveManager.set_slot_data("current_spawn_global_position_x", currentPlayer.global_position.x)
		SaveManager.set_slot_data("current_spawn_global_position_y", currentPlayer.global_position.y + -1)
		print("player position spawn")

func get_first_room() -> String:
	var volume: String = LevelManager.currentVolumeName.to_lower()
	var defaultVolume1Room: String = "room1"
	var defaultVolume2Room: String = "room65"
	
	match volume:
		"volume1":
			return defaultVolume1Room
		"volume2":
			return defaultVolume2Room
	return "room1"

func get_volume_info() -> void: 
	get_important_objects()

func get_important_objects() -> void:
	for room: Room in rooms.get_children():
		#var index: int = 0
		
		for object: Variant in room.get_node("Objects").get_children():
			if object.is_in_group("uniqueCollectable"):
				var collectibleComponent: CollectableComponent = object.get_node("CollectableComponent")
				
				if collectibleComponent != null:
					pass
				
				LevelManager.collectableDict[object] = room
				LevelManager.collectiblesCount += 1
				#print(LevelManager.collectableDict)
			#print("[volume] Object: %s" % object)
	return

func get_room_global_position(roomName: String) -> Vector2:
	if volumeRoomInfo.has(roomName):
		var roomData: Dictionary = volumeRoomInfo[roomName]
		var x: float = roomData.get("global_position_x", 0.0)
		var y: float = roomData.get("global_position_y", 0.0)
		return Vector2(x, y)
	else:
		Utils.debug_print(self, "room '%s' not found in volumeRoomInfo", [roomName])
		return Vector2()

func get_room_bounds(roomName: String) -> Rect2:
	if volumeRoomInfo.has(roomName):
		var roomData: Dictionary = volumeRoomInfo[roomName]
		var boundsData: Dictionary = roomData.get("global_bounds", {})
		var posData: Vector2 = Vector2(
			boundsData.get("position_x", 0.0),
			boundsData.get("position_y", 0.0)
		)
		var sizeData: Vector2 = Vector2(
			boundsData.get("size_x", 0.0),
			boundsData.get("size_y", 0.0)
		)
		return Rect2(posData, sizeData)
	else:
		Utils.debug_print(self, "room '%s' not found in volumeRoomInfo", [roomName])
		return Rect2()

func on_instance_invalid(instance: Node) -> void:
	Utils.debug_print(self, "instance '%s' is invalid or null", [instance])
