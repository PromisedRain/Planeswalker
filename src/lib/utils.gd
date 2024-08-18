extends Node

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var main: Node = get_tree().get_first_node_in_group("main")
@onready var outsideSubViewportCamera: Camera2D = get_tree().get_first_node_in_group("outsideSubViewportCamera")
@onready var insideSubViewportCamera: Camera2D = get_tree().get_first_node_in_group("insideSubViewportCamera")

var fireDebugs: bool = false


func _ready() -> void:
	if !fireDebugs:
		print("[utils] Debug prints are off")
	
	var uuid: String = generate_uuid()
	debug_print(self, "test uuid: %s", [uuid])

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
	#outsideSubViewportCamera = get_tree().get_first_node_in_group("outsideSubViewportCamera")
	#insideSubViewportCamera = get_tree().get_first_node_in_group("insideSubViewportCamera")

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

func get_first_non_repeat_char(s: String) -> String:
	var count: Dictionary = {}
	
	for c in s:
		count[c] = 1 + count.get(c, 0)
	
	for c in count:
		if count[c] == 1:
			return c
	return "_"

func debug_print(_self: Variant, comment: String, args: Array = []) -> void:
	if !fireDebugs:
		return
	
	#comment = letter_to_upper(comment[0] + comment.substr(1))
	
	if comment[0] != letter_to_upper(comment[0]):
		comment[0] = letter_to_upper(comment[0])
	
	var formattedComment: String = comment
	
	if args.size() > 0:
		formattedComment = comment % args
	
	_self = _self.get_name().to_lower()
	
	print("[%s] %s" % [str(_self), formattedComment])

func letter_to_upper(letter: String) -> String:
	return letter.capitalize()
