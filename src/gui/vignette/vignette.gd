extends CanvasLayer

@export var layerIndex: LayerManager.Layers

func _ready() -> void:
	if layerIndex != LayerManager.Layers.PLACEHOLDER_LAYER:
		LayerManager.set_layer_index(self, layerIndex)
