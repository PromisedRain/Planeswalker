extends Node2D


@onready var roomsContainer = $Rooms

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var defaultVolumeSpawnLocation: Vector2i
@export var volumeSpawn: bool

var currentRoom: Room
var currentCamera: Camera2D
var currentPlayer: CharacterBody2D
var rooms

func _ready() -> void:
	LevelManager.currentVolume = self
	
	

func update_current_room(inputRoom: Room) -> void:
	print("updating current room")
	
	currentRoom = inputRoom
	LevelManager.currentRoom = currentRoom
	LevelManager.currentRoomFilepath = currentRoom.filename
	LevelManager.currentRoomPosition = currentRoom.global_position

func player_died() -> void:
	print("player died")
	
	reload_room()
	reload_camera()
	var player = LevelManager.create_player_instance()
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func free_all_rooms() -> void:
	for room: Room in roomsContainer:
		room.queue_free()

func reload_room() -> void:
	var roomPath = str(LevelManager.currentRoomPath)
	var roomInstance: Room = load(roomPath).instantiate()
	var oldRoom = currentRoom

func reload_camera() -> void:
	var camera: Camera2D = currentCamera
	camera.queue_free()
	camera = LevelManager.create_camera_instance()
	add_child(camera)
	#camera.reset_camera()

