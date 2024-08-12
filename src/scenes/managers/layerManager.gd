extends Node

enum Layers {
	PLACEHOLDER_LAYER = 0,
	
	PARALLAX_BACKDROP_LAYER = 8, # parallax layer, includes multiple layers
	STATIC_BACKDROP_LAYER = 9, # stuff that might be close to the background but not far away like the parallax layer, more desaturated
	
	TILE_BACKGROUND_LAYER = 11,
	TILE_BACKGROUND_PROPS_FRONT_LAYER = 12,
	TILE_BACKGROUND_SPIKES_LAYER = 13,
	
	ENTITY_LAYER = 14,
	ENTITY_FRONT_LAYER = 15,
	
	TILE_FOREGROUND_SPIKES_LAYER = 16, # spikes that are behind foundation layer
	TILE_SOLID_LAYER = 17, # the layer you actually collide with
	TILE_BLACK_FILL_BACKGROUND_LAYER = 18, # the black background
	TILE_RANDOMIZED_INFILL_LAYER = 19, #
	TILE_FOREGROUND_PROPS_FRONT_LAYER = 20, # grass, snow blobs, sand, vines, etc.
	
	ROOM_GRADIENT_LAYER = 22, # subtle gradient that eases the color from the beginning to the end of a room
	ROOM_FOREGROUND_PARTICLES_LAYER = 23, # stuff like rain, snow, etc.
	
	VIGNETTE_LAYER = 25,
	DEBUG_CONSOLE_LAYER = 26,
	
	PAUSE_MENU_LAYER = 30,
	MENU_LAYER = 31,
	
	TRANSITION_LAYER = 40
}

func set_z_index(node: Node2D, index: Layers) -> void:
	node.z_index = index

func set_dynamic_z_index(node: Node2D) -> void:
	node.z_index = int(node.position.y)

func set_canvas_layer(node: CanvasLayer, index: Layers) -> void:
	node.layer = index
