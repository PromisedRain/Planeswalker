class_name Room
extends Node2D

@onready var doors: Node2D = $Doors
@onready var decorations: Node2D = $Decorations
@onready var objects: Node2D = $Objects
@onready var world: Node2D = get_parent().get_parent()
@onready var tileSolidLayer: AutoTilerComponent = $TileSolidLayer

var currentCheckpoint: RoomCheckpoint = null
var objectChildren: Array = []
var adjacentRooms: Array = []

var minXFull: int
var minYFull: int
var maxXFull: int
var maxYFull: int

#var roomWidth: int
#var roomHeight: int
#var roomCenter: Vector2

var roomName: String

signal room_entered(room: Room)

func _ready() -> void:
	roomName = self.name.to_lower()
	
	initalize_checkpoints()

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
	
	#roomWidth = minXFull + maxXFull
	#roomHeight = minYFull + maxYFull
	#roomCenter = Vector2((minXFull + maxXFull) / 2, (minYFull + maxYFull) / 2)

func get_global_room_bounds() -> Rect2:
	var localRoomBounds: Rect2 = get_local_room_bounds()
	
	var globalPos: Vector2 = global_position + localRoomBounds.position
	var globalSize: Vector2 = localRoomBounds.size
	
	var globalRoomBounds: Rect2 = Rect2(globalPos, globalSize)
	return globalRoomBounds

func get_local_room_bounds() -> Rect2:
	calculate_room_bounds()
	
	var pos: Vector2 = Vector2(minXFull, minYFull)
	var size: Vector2 = Vector2(maxXFull - minXFull, maxYFull - minYFull)
	return Rect2(pos, size)
