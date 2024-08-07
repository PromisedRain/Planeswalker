class_name Volume
extends Node2D

@onready var roomsContainer: Node2D = $Rooms
@onready var objects: Node2D = $Objects
@onready var worldEnvironment: WorldEnvironment = $WorldEnvironment
@onready var canvasModulate: CanvasModulate = $CanvasModulate

@export var volumeGivenTitle: String
@export_range(1,3) var volumeID: int
@export var defaultVolumeSpawnLocation: Vector2i
@export var volumeSpawn: bool

var currentRoom: Room
var currentCamera: Camera2D
var currentPlayer: CharacterBody2D
var rooms

func _ready() -> void:
	update_current_volume()
	free_all_rooms()
	load_current_room()

func load_current_room() -> void:
	var roomName: String = SaveManager.get_slot_data("current_room")
	
	if roomName == null || roomName == "":
		print("[volume] No saved room found, loading default")
		var defaultFirstRoom: String = get_current_volume_first_room_name()
		#print(defaultFirstRoom)
		LevelManager.load_room(defaultFirstRoom, roomsContainer)
		return
	
	print("[volume] Loading saved room")
	LevelManager.load_room(roomName, roomsContainer)

func update_current_volume() -> void:
	print("updating current volume")
	
	LevelManager.currentVolume = self
	LevelManager.currentVolumeName = get_name()

func update_current_room(inputRoom: Room) -> void:
	print("updating current room")
	
	currentRoom = inputRoom
	LevelManager.currentRoom = currentRoom
	LevelManager.currentRoomName = currentRoom.roomName
	LevelManager.currentRoomPosition = currentRoom.global_position

func get_current_volume_first_room_name() -> String:
	var volume: String = LevelManager.currentVolumeName.to_lower()
	
	var defaultVolume1: String = "room1"
	var defaultVolume2: String = "room65"
	
	match volume:
		"volume1":
			print("volume is 1")
			return defaultVolume1
		"volume2":
			print("volume is 2")
			return defaultVolume2
	
	return "room1"



func player_died() -> void:
	print("player died")
	
	reload_room()
	reload_camera()
	var player = LevelManager.get_player_instance()
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func free_all_rooms() -> void:
	print("freeing all rooms")
	
	for room: Room in roomsContainer.get_children():
		room.queue_free()

func reload_room() -> void:
	var roomPath: String = str(LevelManager.currentRoomPath)
	var roomInstance: Room = load(roomPath).instantiate()
	var oldRoom: Room = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = LevelManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

