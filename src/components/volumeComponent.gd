class_name VolumeComponent
extends Node2D

@onready var roomsContainer: Node2D = $Rooms
@onready var objects: Node2D = $Objects
@onready var worldEnvironment: WorldEnvironment = $WorldEnvironment
@onready var canvasModulate: CanvasModulate = $CanvasModulate

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var volumeSpawn: Marker2D
@export var spawnOnDefault: bool

var currentRoom: RoomComponent
var currentCamera: Camera2D
var currentPlayer: Player
var rooms

func _ready() -> void:
	
	
	
	update_current_volume()
	free_all_rooms()
	load_current_room()
	get_important_info()
	
	SaveManager.save_game()

func load_current_room() -> void:
	var roomName: String = SaveManager.get_slot_data("current_room")
	
	if roomName == null || roomName == "":
		print("[volume] No saved room found, loading default")
		var defaultFirstRoom: String = get_first_room()
		
		if !LevelManager.load_room(defaultFirstRoom, roomsContainer):
			print("[volume] Failed to load default room: %s" % defaultFirstRoom)
		return
	
	#print("[volume] Loading saved room")
	if !LevelManager.load_room(roomName, roomsContainer):
		print("[volume] Failed to load saved room: %s" % roomName)

func update_current_volume() -> void:
	print("[volume] Updating current volume")
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumePath = str(LevelManager.volumePath + "/" + LevelManager.currentVolumeName.to_lower())
	LevelManager.currentVolumeName = get_name()
	
	var slot: int = SaveManager.currentSaveSlot
	var latestVolumeID: int = int(SaveManager.get_slot_data("current_volume"))
	
	if volumeID > latestVolumeID:
		print("[volume] New volume reached")
		
		SaveManager.set_specific_slot_meta_data(slot, "current_volume", volumeID)
		SaveManager.set_specific_slot_meta_data(slot, "latest_volume_name", volumeGivenName)
		SaveManager.save_current_meta_data()
		
		SaveManager.set_slot_data("current_volume", volumeID)
		SaveManager.save_slot(slot, SaveManager.currentSlotData)
	else:
		print("[volume] Current volume ID is not higher than saved, no update required")

func update_current_room(inputRoom: RoomComponent) -> void:
	print("[volume] Updating current room")
	
	currentRoom = inputRoom
	LevelManager.currentRoom = currentRoom
	LevelManager.currentRoomName = currentRoom.roomName
	LevelManager.currentRoomPosition = currentRoom.global_position

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
	print("[volume] Player died")
	
	reload_room()
	reload_camera()
	var player = LevelManager.get_player_instance()
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func free_all_rooms() -> void:
	for room: RoomComponent in roomsContainer.get_children():
		room.queue_free()

func reload_room() -> void:
	var roomPath: String = str(LevelManager.currentRoomPath)
	var roomInstance: RoomComponent = load(roomPath).instantiate()
	var oldRoom: RoomComponent = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = LevelManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

func get_important_info() -> void: 
	get_important_objects()

func get_important_objects() -> void:
	for room: RoomComponent in roomsContainer.get_children():
		var index: int = 0
		
		for object: Variant in room.get_node("Objects").get_children():
			if object.is_in_group("uniqueCollectable"):
				var collectibleComponent: CollectableComponent = object.get_node("CollectableComponent")
				
				if collectibleComponent != null:
					pass
				
				LevelManager.collectableDict[object] = room
				LevelManager.collectiblesCount += 1
				print(LevelManager.collectableDict)
			#print("[volume] Object: %s" % object)
	
	return
	#print(LevelManager.collectiblesCount)


func save_player_global_pos() -> void:
	pass
	#SaveManager.set_slot_data("current_chapter_position_x", player.global_position.x)
	#SaveManager.set_slot_data("current_chapter_position_y", player.global_position.y)
