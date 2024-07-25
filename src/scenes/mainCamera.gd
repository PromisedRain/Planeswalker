extends Node2D

@onready var player: CharacterBody2D = NodeUtility.get_player()
@onready var camera2d: Camera2D = $Camera2D

func _physics_process(delta) -> void:
	update_camera()

func _process(delta) -> void:
	update_camera()

func update_camera() -> void:
	pass
	#if is_instance_valid(player):
	#	camera2d.position = player.position
