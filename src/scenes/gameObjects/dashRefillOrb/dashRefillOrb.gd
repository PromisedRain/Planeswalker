extends Node2D

@onready var player: CharacterBody2D = NodeUtility.get_player()

func _on_area_2d_body_entered(body) -> void:
	if !body == player:
		return
	
	player.refill_dashes()
	queue_free()
