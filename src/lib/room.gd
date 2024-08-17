class_name Room
extends Node2D

@onready var doors: Node2D = $Doors
@onready var decorations: Node2D = $Decorations
@onready var objects: Node2D = $Objects
@onready var world: Node2D = get_parent().get_parent()
@onready var tileSolidLayer: AutoTilerComponent = $TileSolidLayer

var usedCheckpoint: Node2D = null
var objectChildren: Array = []
var adjacentRooms: Array = []

var minX: int
var minY: int
var maxX: int
var maxY: int

var minXFull: int
var minYFull: int
var maxXFull: int
var maxYFull: int

var roomWidth: int
var roomHeight: int
var roomCenter: int

signal enteredRoom(room: Room)

func _ready() -> void:
	enteredRoom.emit(self)
	
	for door: RoomSwitcherComponent in doors.get_children():
		door.playerEntered.connect(room_entered)
	
	calculate_room_bounds()
	print(roomWidth)
	print(roomHeight)
	print("[Room] Room bounds: (%d, %d, %d, %d)" % [minXFull, minYFull, maxXFull, maxYFull])

func room_entered() -> void:
	pass

func calculate_room_bounds() -> void:
	var cells = tileSolidLayer.get_used_cells()
	var tileSize = tileSolidLayer.tile_set.tile_size
	if cells.size() == 0:
		return
	
	minX = cells[0].x
	minY = cells[0].y
	maxX = cells[0].x
	maxY = cells[0].y
	
	for cell in cells:
		if cell.x < minX:
			minX = cell.x
		if cell.x > maxX:
			maxX = cell.x
		if cell.y < minY:
			minY = cell.y
		if cell.y > maxY:
			maxY = cell.y
	
	minXFull = minX * tileSize.x
	minYFull = minY * tileSize.y
	maxXFull = maxX * tileSize.x
	maxYFull = maxY * tileSize.y
	
	roomWidth = minXFull + maxXFull
	roomHeight = minYFull + maxYFull
	roomCenter = (minXFull - maxYFull)

func set_parent_for_room_switchers() -> void:
	for door: RoomSwitcherComponent in doors.get_children():
		door.parentRoom = self

func get_adjacent_rooms() -> Array:
	adjacentRooms.append(self)
	for door: RoomSwitcherComponent in doors.get_children():
		if door.get_adjacent_room() != null:
			adjacentRooms.append(door.get_adjacent_room())
	return adjacentRooms
