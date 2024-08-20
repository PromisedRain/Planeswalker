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

var roomPositions: Dictionary = {}
var roomBoundaries: Dictionary = {}

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
	
	free_all_rooms()
	load_current_room()
	load_current_spawn()
	
	get_important_info()
	#calculate_adjacency()
	
	SaveManager.save_game()

func load_current_room() -> void:
	var saveRoomName: String = SaveManager.get_slot_data("current_room")
	var progress: LevelManager.SceneLoadProgress
	
	if saveRoomName == null || saveRoomName == "":
		Utils.debug_print(self, "no saved room found, loading default")
		var defaultFirstRoomName: String = get_first_room()
		
		progress = LevelManager.load_room(defaultFirstRoomName, Callable(self, "on_room_load"))
		handle_room_load_progress(progress)
		return
	
	progress = LevelManager.load_room(saveRoomName, Callable(self, "on_room_load"))
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

func on_room_load(loadedScene: PackedScene, sceneName: String) -> void:
	if !loadedScene is PackedScene:
		Utils.debug_print(self, "failed to load scene '%s'", [loadedScene])
		return
	
	var roomInstance: Room = loadedScene.instantiate()
	var roomGlobalPosition: Vector2 = roomPositions[sceneName]
	
	roomInstance.global_position = roomGlobalPosition
	rooms.add_child(roomInstance)

func update_current_volume() -> void:
	Utils.debug_print(self, "updating current volume")
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumeName = get_name()
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

func update_current_room(_room: Room) -> void:
	print("[volume] Updating current room")
	
	
	currentRoom = _room
	LevelManager.currentRoom = _room
	LevelManager.currentRoomName = _room.roomName

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
	roomPositions.clear()
	
	for room: Room in rooms.get_children():
		roomPositions[room.name.to_lower()] = room.global_position
	print(roomPositions)

func save_room_global_bounds() -> void:
	roomBoundaries.clear()
	
	for room: Room in rooms.get_children():
		var roomBounds: Rect2 = room.get_global_room_bounds()
		roomBoundaries[room.name.to_lower()] = roomBounds
	print(roomBoundaries)

func process_room() -> void:
	calculate_adjacency()

func calculate_adjacency() -> void:
	var adjacentRoomNames: Array[String] = get_adjacent_rooms()
	print(adjacentRoomNames)

func get_adjacent_rooms() -> Array[String]:
	var adjacentRooms: Array[String] = []
	var nonAdjacentRooms: Array[String] = []
	var currentBounds: Rect2 = currentRoom.get_global_room_bounds()
	
	for roomName in roomBoundaries.keys():
		if roomName == currentRoom.name.to_lower():
			continue
		
		var bounds: Rect2 = roomBoundaries[roomName]
		if are_rooms_adjacent(currentBounds, bounds):
			adjacentRooms.append(roomName)
		else:
			nonAdjacentRooms.append(roomName)
	return adjacentRooms

func are_rooms_adjacent(bounds1: Rect2, bounds2: Rect2) -> bool:
	var expandedBounds1: Rect2 = Rect2(bounds1.position - Vector2(roomAdjacencyThreshold, roomAdjacencyThreshold),
	bounds1.size + Vector2(roomAdjacencyThreshold * 2, roomAdjacencyThreshold * 2))
	return expandedBounds1.intersects(bounds2)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_reload_room"):
		#if GlobalManager.debugMode:
		#reload_camera()
		reload_room()

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
	#print(LevelManager.collectiblesCount)


func save_player_global_pos() -> void:
	SaveManager.set_slot_data("current_spawn_global_position_x", player.global_position.x)
	SaveManager.set_slot_data("current_spawn_global_position_y", player.global_position.y)
