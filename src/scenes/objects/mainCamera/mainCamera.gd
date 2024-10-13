class_name MainCamera
extends Camera2D

@onready var player: Player = Utils.get_player()

func reset_initial_position(target: Node2D) -> void:
	reset_smoothing()
	global_position = target.global_position
	position_smoothing_enabled = true
