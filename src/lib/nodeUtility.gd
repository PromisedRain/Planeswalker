extends Node


@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var main: Node = get_tree().get_first_node_in_group("main")
@onready var mainCamera: Camera2D = get_tree().get_first_node_in_group("mainCamera")

func get_player() -> CharacterBody2D:
	return player

func get_main() -> Node:
	return main

func get_main_camera() -> Camera2D:
	return mainCamera

func is_approximately_equal(a: float, b: float, epsilon: float = 0.01) -> bool:
	return abs(a - b) < epsilon

func int_lerp(start: int, target: int, multiplier: float) -> int:
	return int(start + (target - start) * multiplier)
