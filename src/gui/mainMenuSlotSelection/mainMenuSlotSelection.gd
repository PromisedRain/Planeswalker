extends Node2D

@onready var slot1Title: Label = $CanvasLayer/Control/MarginContainer/Control/MarginContainer/HBoxContainer/Slot1/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/Slot1Title
@onready var slot2Title: Label = $CanvasLayer/Control/MarginContainer/Control/MarginContainer/HBoxContainer/Slot2/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/Slot2Title
@onready var slot3Title: Label = $CanvasLayer/Control/MarginContainer/Control/MarginContainer/HBoxContainer/Slot3/VBoxContainer/TextureRect/MarginContainer/VBoxContainer/Slot3Title

@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"CanvasLayer/StarParticles"

func _ready() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	starParticles.emitting = true
