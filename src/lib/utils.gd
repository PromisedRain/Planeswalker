extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var main: Node = get_tree().get_first_node_in_group("main")
@onready var outsideSubViewportCamera: Camera2D = get_tree().get_first_node_in_group("outsideSubViewportCamera")
@onready var insideSubViewportCamera: Camera2D = get_tree().get_first_node_in_group("insideSubViewportCamera")

func _ready() -> void:
	var uuid: String = generate_uuid()
	print("[utils] Test uuid: %s" % uuid)

func get_player() -> Player:
	update_references()
	return player

func get_main() -> Node:
	update_references()
	return main

func get_outside_sub_viewport_camera() -> Camera2D:
	update_references()
	if outsideSubViewportCamera == null:
		return
	return outsideSubViewportCamera

func get_inside_sub_viewport_camera() -> Camera2D:
	update_references()
	if insideSubViewportCamera == null:
		return
	return insideSubViewportCamera

func update_references() -> void:
	player = get_tree().get_first_node_in_group("player")
	main = get_tree().get_first_node_in_group("main")
	outsideSubViewportCamera = get_tree().get_first_node_in_group("outsideSubViewportCamera")
	insideSubViewportCamera = get_tree().get_first_node_in_group("insideSubViewportCamera")

func is_approximately_equal(a: float, b: float, epsilon: float = 0.01) -> bool:
	return abs(a - b) < epsilon

func int_lerp(start: int, end: int, weight: float) -> int:
	return int(start + (end - start) * weight)

func generate_uuid() -> String:
	var pattern: String = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	var uuid: String = ""
	
	for i: int in pattern.length():
		var c: String = pattern[i]
		
		if c == "x" || c == "y":
			var r: int = randi() % 16
			var v: int
			
			if c == "x":
				v = r
			else:
				v = (r & 0x3) | 0x8
			uuid += to_hex_char(v)
		else:
			uuid += c
	return uuid

func to_hex_char(value: int) -> String:
	var hexChars: Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
	return hexChars[value]

func get_check_word(passed: bool) -> String:
	if passed:
		return "passed"
	else:
		return "failed"
