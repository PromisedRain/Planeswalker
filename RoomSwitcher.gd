class_name RoomSwitcher
extends Node2D

@onready var upRay: RayCast2D = $Area2D/Up
@onready var rightRay: RayCast2D = $Area2D/Right
@onready var leftRay: RayCast2D = $Area2D/Left
@onready var collisionShape2d: CollisionShape2D = $Area2D/CollisionShape2D


@export_enum("left", "right", "up", "down") var roomDirection
@export var pushDistance: int = 16
@export var collisionShapeScale: Vector2 = Vector2(1.0, 1.0)

signal playerEntered(door: RoomSwitcher)

var roomSwitcherType: String = "ROOMSWITCHER"

var adjacentRoomSwitcher: RoomSwitcher = null
var parentRoom: Room = null

func get_adjacent_room() -> Room:
	if adjacentRoomSwitcher != null:
		return
	
	rightRay.force_raycast_update()
	if rightRay.is_colliding():
		var _adjacentRoomSwitcher: RoomSwitcher = rightRay.get_collider().get_parent()
		if _adjacentRoomSwitcher.get("roomSwitcherType") == roomSwitcherType && _adjacentRoomSwitcher is RoomSwitcher:
			adjacentRoomSwitcher = _adjacentRoomSwitcher
			_adjacentRoomSwitcher.adjacentRoomSwitcher = self
			return adjacentRoomSwitcher.parentRoom
	
	leftRay.force_raycast_update()
	if leftRay.is_colliding():
		var _adjacentRoomSwitcher: RoomSwitcher = leftRay.get_collider().get_parent()
		if _adjacentRoomSwitcher.get("roomSwitcherType") == roomSwitcherType && _adjacentRoomSwitcher is RoomSwitcher:
			adjacentRoomSwitcher = _adjacentRoomSwitcher
			_adjacentRoomSwitcher.adjacentRoomSwitcher = self
			return adjacentRoomSwitcher.parentRoom
	return null


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body is Player:
		return
	
	playerEntered.emit(self)
