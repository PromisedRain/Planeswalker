extends Camera2D

const RESOLUTION = Vector2(320, 180)


func _process(_delta: float) -> void:
	position = round_to_pixel(global_position)

func round_to_pixel(position):
	return Vector2(round(position.x), round(position.y))
