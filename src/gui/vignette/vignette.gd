extends CanvasLayer

@export var zIndexLayer: LayerManager.Layers

func _ready() -> void:
	LayerManager.set_canvas_layer(self, zIndexLayer)
