extends Node2D


@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"CanvasLayer/StarParticles"

func _ready() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	starParticles.emitting = true

func _process(delta: float) -> void:
	pass
