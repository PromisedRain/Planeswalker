@tool
class_name AutoTilerComponent
extends TileMapLayer

@export var useTool: bool = false
@export var lockRandomPattern: bool = false
@export var seedInput: int = 0  
@export var layerIndex: LayerManager.Layers

func _ready() -> void:
	if !Engine.is_editor_hint():
		if layerIndex != LayerManager.Layers.PLACEHOLDER_LAYER:
			LayerManager.set_layer_index(self, layerIndex)

func add_border_collision_tiles() -> void:
	if Engine.is_editor_hint():
		if useTool:
			print("using tool")
		
		useTool = false
