extends Node


var player: CharacterBody2D = null
var main: Node = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	main = get_tree().get_first_node_in_group("main")

func get_player() -> CharacterBody2D:
	return player

func get_main() -> Node:
	return main
