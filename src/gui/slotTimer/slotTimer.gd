extends CanvasLayer

@export var ZIndexLayer: LayerManager.Layers

func _ready() -> void:
	LayerManager.set_canvas_layer(self, ZIndexLayer)
	
	load_initial_slot_time()

func load_initial_slot_time() -> void:
	pass
