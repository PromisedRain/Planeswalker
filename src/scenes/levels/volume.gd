extends Node2D

@export var volumeGivenName: String
@export_range(1,3) var volumeID: int
@export var defaultVolumeSpawnLocation: Vector2i
@export var volumeSpawn: bool


func _ready() -> void:
	
	
	LevelManager.currentWorld = self

func player_died() -> void:
	print("player died")
