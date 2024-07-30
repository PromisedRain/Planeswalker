extends Node2D

@onready var windowScreenSize: Vector2i = get_viewport().get_visible_rect().size
@onready var starParticles: CPUParticles2D = $"CanvasLayer/StarParticles"


func _ready() -> void:
	starParticles.emission_rect_extents = windowScreenSize
	starParticles.emitting = true

signal openSettings
signal openEnter


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	emit_signal("openSettings")


func _on_enter_pressed() -> void:
	emit_signal("openEnter")
