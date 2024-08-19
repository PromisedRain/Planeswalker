class_name Room
extends Node2D

@onready var doors: Node2D = $Doors
@onready var decorations: Node2D = $Decorations
@onready var objects: Node2D = $Objects
@onready var world: Node2D = get_parent().get_parent()
@onready var tileSolidLayer: AutoTilerComponent = $TileSolidLayer

var usedCheckpoint: RoomCheckpoint = null
var objectChildren: Array = []
var adjacentRooms: Array = []

#var minX: int
#var minY: int
#var maxX: int
#var maxY: int

var minXFull: int
var minYFull: int
var maxXFull: int
var maxYFull: int

var roomWidth: int
var roomHeight: int
var roomCenter: Vector2

var globalMinX: float
var globalMinY: float
var globalMaxX: float
var globalMaxY: float

signal room_entered(room: Room)

func _ready() -> void:
	initalize_checkpoints()
	for checkpoint: RoomCheckpoint in doors.get_children():
		checkpoint.entered_checkpoint.connect(on_checkpoint_entered)

func on_checkpoint_entered(checkpoint: RoomCheckpoint) -> void:
	room_entered.emit(self)

func initalize_checkpoints() -> void:
	for checkpoint: RoomCheckpoint in doors.get_children():
		checkpoint.entered_checkpoint.connect(on_checkpoint_entered)
		checkpoint.parentRoom = self

func calculate_room_bounds() -> void:
	var cells: Array[Vector2i] = tileSolidLayer.get_used_cells()
	var tileSize: Vector2i = tileSolidLayer.tile_set.tile_size
	if cells.size() == 0:
		return
	
	var minX: int = cells[0].x
	var minY: int = cells[0].y
	var maxX: int = cells[0].x
	var maxY: int = cells[0].y
	
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
	
	var globalPos: Vector2 = global_position
	
	globalMinX = globalPos.x + minX * tileSize.x
	globalMinY = globalPos.y + minY * tileSize.y
	globalMaxX = globalPos.x + maxX * tileSize.x
	globalMaxY = globalPos.y + maxY * tileSize.y
	
	roomWidth = minXFull + maxXFull
	roomHeight = minYFull + maxYFull
	roomCenter = Vector2((minXFull + maxXFull) / 2, (minYFull + maxYFull) / 2)

func get_global_room_bounds() -> Rect2:
	#calculate_room_bounds()
	var localRoomBounds: Rect2 = get_local_room_bounds()
	print(localRoomBounds)
	
	var pos: Vector2 = Vector2(globalMinX, globalMinY)
	var size: Vector2 = Vector2(globalMaxX - globalMinX, globalMaxY - globalMinY) 
	return Rect2(pos, size)

func get_local_room_bounds() -> Rect2:
	calculate_room_bounds()
	
	var pos: Vector2 = Vector2(minXFull, minYFull)
	var size: Vector2 = Vector2(maxXFull - minXFull, maxYFull - minYFull)
	return Rect2(pos, size)

func set_parent_for_room_switchers() -> void:
	for door: RoomSwitcherComponent in doors.get_children():
		door.parentRoom = self
