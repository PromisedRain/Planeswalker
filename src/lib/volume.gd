class_name Volume
extends Node2D

@onready var rooms: Node2D = $Rooms
@onready var objects: Node2D = $Objects
@onready var worldEnvironment: WorldEnvironment = $WorldEnvironment
@onready var canvasModulate: CanvasModulate = $CanvasModulate

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var volumeSpawn: Marker2D
@export var volumeDebugSpawn: Marker2D
@export var spawnDebug: bool

var roomGlobalPositions: Dictionary = {}
var roomGlobalBounds: Dictionary = {}

var volumesDirPath: String = "user://volumes"

const roomAdjacencyThreshold: float = 20.0

var currentRoom: Room
var currentCamera: Camera2D #change this type to the camera class i will make through cameraManager

var player: Player

#TODO update current room when volume loads based on current room. make a process_room function to handle entering a new room

func _ready() -> void:
	#TODO change the worldenvironments and canvasmodulate based on volume in levelmanager or something?
	
	update_current_volume()
	
	save_room_global_positions()
	save_room_global_bounds()
	
	SaveManager.ensure_dir_path_exists(volumesDirPath)
	
	build_volume_info_file(volumeID)
	
	free_all_rooms()
	load_current_room()
	load_current_spawn()
	
	get_important_info()
	
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
		add_player_instance_and_set_pos(playerInstance, debugSpawnGlobalPosition)
		return
	
	if saveSpawnGlobalPosition == Vector2.ZERO:
		Utils.debug_print(self, "spawn: default spawn")
		var defaultSpawnGlobalPosition: Vector2 = volumeSpawn.global_position
		add_player_instance_and_set_pos(playerInstance, defaultSpawnGlobalPosition)
		return
	
	Utils.debug_print(self, "spawn: save spawn")
	add_player_instance_and_set_pos(playerInstance, saveSpawnGlobalPosition)

func add_player_instance_and_set_pos(_player: Player, _pos: Vector2) -> void:
	_player.global_position = _pos
	objects.add_child(_player)

func handle_room_load_progress(progress: LevelManager.SceneLoadProgress) -> void:
	match progress:
		LevelManager.SceneLoadProgress.LOADING:
			pass
			#Utils.debug_print(self, "loading ")
		LevelManager.SceneLoadProgress.ADDED_TO_LOAD_QUEUE:
			pass

func on_room_load(loadedScene: PackedScene, sceneName: String, autoUpdateRoom: bool = false) -> void:
	if !loadedScene is PackedScene:
		Utils.debug_print(self, "failed to load scene '%s'", [loadedScene])
		return
	
	var roomInstance: Room = loadedScene.instantiate()
	var roomGlobalPosition: Vector2 = roomGlobalPositions[sceneName]
	
	roomInstance.global_position = roomGlobalPosition
	rooms.add_child(roomInstance)
	
	if autoUpdateRoom:
		update_current_room(roomInstance)
		process_room(roomInstance)

func update_current_volume() -> void:
	Utils.debug_print(self, "updating current volume to: %s" % self.get_name())
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumeName = self.get_name()
	#LevelManager.currentVolumePath = str(LevelManager.volumePath + "/" + LevelManager.currentVolumeName.to_lower())
	
	var slot: int = SaveManager.currentSaveSlot
	var latestVolumeID: int = int(SaveManager.get_slot_data("current_volume"))
	
	if volumeID > latestVolumeID:
		Utils.debug_print(self, "new volume reached")
		
		SaveManager.set_specific_slot_meta_data(slot, "current_volume", volumeID)
		SaveManager.set_specific_slot_meta_data(slot, "latest_volume_name", volumeGivenName)
		SaveManager.save_current_meta_data()
		
		SaveManager.set_slot_data("current_volume", volumeID)
		SaveManager.save_slot(slot, SaveManager.currentSlotData)
	else:
		Utils.debug_print(self, "current volume ID not higher than saved, no update required")

func update_current_room(room: Room) -> void:
	print("[volume] Updating current room")
	
	
	currentRoom = room
	LevelManager.currentRoom = room
	LevelManager.currentRoomName = room.roomName

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

func player_died() -> void:
	Utils.debug_print(self, "player died")
	
	reload_room()
	reload_camera()
	
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func free_all_rooms() -> void:
	for room: Room in rooms.get_children():
		room.queue_free()

func save_room_global_positions() -> void:
	roomGlobalPositions.clear()
	
	for room: Room in rooms.get_children():
		roomGlobalPositions[room.name.to_lower()] = room.global_position
	print(roomGlobalPositions)

func save_room_global_bounds() -> void:
	roomGlobalBounds.clear()
	
	for room: Room in rooms.get_children():
		var roomBounds: Rect2 = room.get_global_room_bounds()
		roomGlobalBounds[room.name.to_lower()] = roomBounds
	print(roomGlobalBounds)

func process_room(_currentRoom: Room) -> void: 
	#whenever i enter a room / it gets called when i enter a checkpoint i havent entered before.
	var _rooms: Dictionary = get_non_and_adjacent_rooms()
	
	free_non_adjacent_rooms(_rooms["non_adjacent_rooms"])
	load_adjacent_rooms(_rooms["adjacent_rooms"])

func free_non_adjacent_rooms(_rooms: Array[String]) -> void:
	for roomName: String in _rooms:
		print("non adjacent")
		print(roomName)

func load_adjacent_rooms(_rooms: Array[String]) -> void:
	for roomName: String in _rooms:
		print("adjacents")
		print(roomName)
 
func get_non_and_adjacent_rooms() -> Dictionary: #Array[String]:
	var adjacentRooms: Array[String] = []
	var nonAdjacentRooms: Array[String] = []
	var bothRoomsDict: Dictionary = {}
	var currentBounds: Rect2 = currentRoom.get_global_room_bounds()
	
	for roomName in roomGlobalBounds.keys():
		if roomName == currentRoom.name.to_lower():
			continue
		
		var bounds: Rect2 = roomGlobalBounds[roomName]
		if are_rooms_adjacent(currentBounds, bounds):
			adjacentRooms.append(roomName)
		else:
			nonAdjacentRooms.append(roomName)
	
	bothRoomsDict["adjacent_rooms"] = adjacentRooms
	bothRoomsDict["non_adjacent_rooms"] = nonAdjacentRooms
	return bothRoomsDict

func are_rooms_adjacent(bounds1: Rect2, bounds2: Rect2) -> bool:
	var expandedBounds1: Rect2 = Rect2(bounds1.position - Vector2(roomAdjacencyThreshold, roomAdjacencyThreshold),
	bounds1.size + Vector2(roomAdjacencyThreshold * 2, roomAdjacencyThreshold * 2))
	return expandedBounds1.intersects(bounds2)

func reload_room() -> void:
	print("reloading room")
	
	var roomName: String = str(LevelManager.currentRoomName)
	#var roomInstance: Room = load(roomPath).instantiate()
	#var oldRoom: Room = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = LevelManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

func get_important_info() -> void: 
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

func save_player_global_pos() -> void:
	SaveManager.set_slot_data("current_spawn_global_position_x", player.global_position.x)
	SaveManager.set_slot_data("current_spawn_global_position_y", player.global_position.y)

func build_volume_info_file(id: int) -> void:
	pass
