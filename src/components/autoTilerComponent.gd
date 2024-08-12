@tool
class_name AutoTilerComponent
extends TileMapLayer

@export var useTool: bool = false
@export var lockRandomPattern: bool = false
@export var seed: int = 0  
@export var zIndexLayer: LayerManager.Layers

func _ready() -> void:
	z_index = zIndexLayer

func add_border_collision_tiles() -> void:
	if Engine.is_editor_hint():
		if useTool:
			print("using tool")
		
		useTool = false
