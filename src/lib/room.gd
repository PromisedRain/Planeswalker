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
	disable_children_processes()

func on_checkpoint_entered(_checkpoint: RoomCheckpoint, _midLevel: bool) -> void:
	#room_entered.emit(self)
	
	if currentCheckpoint != _checkpoint:
		currentCheckpoint = _checkpoint
		print("set current checkpoint to: %s" % _checkpoint)

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
	
	var localPos: Vector2 = Vector2(minXFull, minYFull)
	var localSize: Vector2 = Vector2(maxXFull - minXFull, maxYFull - minYFull)
	return Rect2(localPos, localSize)


func disable_children_processes() -> void:
	for object in objects.get_children():
		if object is Node:
			object.set_process(false)
			object.set_physics_process(false)
			
			if object is Node2D:
				object.visible = false

func enable_children_processes() -> void:
	for object in objects.get_children():
		if object is Node:
			object.set_process(true)
			object.set_physics_process(true)
			
			if object is Node2D:
				object.visible = true
