extends Marker2D

@onready var player: CharacterBody2D = null
@onready var playerCamera: Camera2D = Utils.get_player_camera()


func _process(delta) -> void:
	if player == null:
		player = Utils.get_player()
		if player == null:
			return
	
	var target: Vector2 = player.global_position
	var targetPosX: int
	var targetPosY: int
	
	
	targetPosX = Utils.int_lerp(global_position.x, target.x, 0.6)
	targetPosY = Utils.int_lerp(global_position.y, target.y, 0.6)
	
	#targetPosX = int(target.x)
	#targetPosY = int(target.y)
	
	global_position = Vector2(targetPosX, targetPosY)
	playerCamera.position = global_position


