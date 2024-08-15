class_name RoomSwitcherComponent
extends Node2D

@onready var upRay: RayCast2D = $Area2D/Up
@onready var rightRay: RayCast2D = $Area2D/Right
@onready var leftRay: RayCast2D = $Area2D/Left
@onready var collisionShape2d: CollisionShape2D = $Area2D/CollisionShape2D


@export_enum("left", "right", "up", "down") var roomDirection
@export var pushDistance: int = 16
@export var collisionShapeScale: Vector2 = Vector2(1.0, 1.0)

signal playerEntered(door: RoomSwitcherComponent)

var roomSwitcherType: String = "ROOMSWITCHER"

var adjacentRoomSwitcher: RoomSwitcherComponent = null
var parentRoom: Room = null

func get_adjacent_room() -> Room:
	if adjacentRoomSwitcher != null:
		return
	
	rightRay.force_raycast_update()
	if rightRay.is_colliding():
		var _adjacentRoomSwitcher: RoomSwitcherComponent = rightRay.get_collider().get_parent()
		if _adjacentRoomSwitcher.get("roomSwitcherType") == roomSwitcherType && _adjacentRoomSwitcher is RoomSwitcherComponent:
			adjacentRoomSwitcher = _adjacentRoomSwitcher
			_adjacentRoomSwitcher.adjacentRoomSwitcher = self
			return adjacentRoomSwitcher.parentRoom
	
	leftRay.force_raycast_update()
	if leftRay.is_colliding():
		var _adjacentRoomSwitcher: RoomSwitcherComponent = leftRay.get_collider().get_parent()
		if _adjacentRoomSwitcher.get("roomSwitcherType") == roomSwitcherType && _adjacentRoomSwitcher is RoomSwitcherComponent:
			adjacentRoomSwitcher = _adjacentRoomSwitcher
			_adjacentRoomSwitcher.adjacentRoomSwitcher = self
			return adjacentRoomSwitcher.parentRoom
	return null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body is Player:
		return
	
	playerEntered.emit(self)
