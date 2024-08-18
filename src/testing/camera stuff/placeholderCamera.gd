extends Camera2D

@onready var player: Player = Utils.get_player()

@export var manualCommand: bool = true

func _ready() -> void:
	pass
	#print(player)

func _process(delta: float) -> void:
	if manualCommand:
		var inputdir: Vector2 = get_input()
		position += inputdir * 200 * delta
	
	
	if player == null:
		player = Utils.get_player()
		if player == null:
			return
		else:
			global_position = player.global_position
	
	#var target: Vector2 = player.global_position
	#var targetPosX: int
	#var targetPosY: int
	
	#targetPosX = Utils.int_lerp(global_position.x, target.x, 0.2)
	#targetPosY = Utils.int_lerp(global_position.y, target.y, 0.2)
	
	
	#position = Vector2(round(targetPosX), round(targetPosY))
	
	#uncomment this for placerholder code
	if player != null && !manualCommand:
		position = Vector2(round(position.x), round(position.y))
		global_position = player.global_position

func get_input() -> Vector2:
	var dir = Input.get_vector("left", "right", "up", "down")
	return dir
