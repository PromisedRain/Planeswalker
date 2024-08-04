extends Node2D

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var defaultVolumeSpawnLocation: Vector2i
@export var volumeSpawn: bool

var currentRoom: Room

func _ready() -> void:
	LevelManager.currentVolume = self

func update_current_room(inputRoom: Room) -> void:
	print("updating current room")
	
	currentRoom = inputRoom
	LevelManager.currentRoom = currentRoom
	LevelManager.currentRoomFilepath = currentRoom.scene_file_path
	LevelManager.currentRoomPos = currentRoom.global_position

func player_died() -> void:
	print("player died")
	
	reload_room()
	reload_camera()
	var player = LevelManager.create_player_instance()
	player.global_position = LevelManager.currentSpawn.round() + Vector2.UP

func reload_room() -> void:
	var roomPath = str(LevelManager.currentRoomPath)
	var roomInstance: Room = load(roomPath).instantiate()
	var oldRoom = currentRoom
	
	

func reload_camera() -> void:
	pass
