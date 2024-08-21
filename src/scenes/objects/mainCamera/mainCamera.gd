class_name MainCamera
extends Camera2D

@onready var player: Player = Utils.get_player()

func reset_initial_position(target: Node2D) -> void:
	position_smoothing_enabled = false
	global_position = target.global_position
	position_smoothing_enabled = true

func _physics_process(_delta: float) -> void:
	if player == null:
		player = Utils.get_player()
		
		if player == null:
			return
		#else:
		#	global_position = player.global_position
	
	#position = Vector2(round(position.x), round(position.y))
	global_position = player.global_position
