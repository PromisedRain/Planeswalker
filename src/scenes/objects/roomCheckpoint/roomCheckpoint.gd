class_name RoomCheckpoint
extends Node2D

@onready var player: Player = Utils.get_player()

var playerInside: bool = false
var parentRoom: Node2D

signal entered_checkpoint(checkpoint: RoomCheckpoint)

func _ready() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = true
	handle_entering()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = false

func handle_entering() -> void:
	entered_checkpoint.emit(self)
