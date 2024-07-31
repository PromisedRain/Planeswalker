extends Node

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var colorRect = $ColorRect

const anims: Dictionary = {
	"clear_to_black": "clear_to_black",
	"black_to_clear": "black_to_clear"
}

func play(animation: String) -> void:
	animationPlayer.play(animation)
	

