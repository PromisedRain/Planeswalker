extends Camera2D

@onready var player: Player = Utils.get_player()

func _ready() -> void:
	#Utils.update_references()
	print(player)

func _process(delta: float) -> void:
	if player == null:
		player = Utils.get_player()
		
		if player == null:
			return
	
	#var target: Vector2 = player.global_position
	#var targetPosX: int
	#var targetPosY: int
	
	#targetPosX = Utils.int_lerp(global_position.x, target.x, 0.2)
	#targetPosY = Utils.int_lerp(global_position.y, target.y, 0.2)
	
	position = Vector2(round(position.x), round(position.y))
	#position = Vector2(round(targetPosX), round(targetPosY))
	global_position = player.global_position
