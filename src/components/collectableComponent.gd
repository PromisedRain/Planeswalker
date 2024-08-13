class_name CollectableComponent
extends Area2D

@onready var player: Player = Utils.get_player()

@export var collisionShape: CollisionShape2D
@export var animationPlayer: AnimationPlayer
@export var hasExitAnim: bool
@export var isUniqueCollectable: bool
@export var uniqueCollectible: ProgressionManager.ProgressionCollectibles

var parent: Node
var finishedRunning: bool

signal collectableEntered

func _ready() -> void:
	if animationPlayer != null:
		animationPlayer.animation_finished.connect(on_anim_finished)
	
	if parent == null:
		parent = get_parent()

func _on_body_entered(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	print("entered collectable")
	
	collectableEntered.emit()
	
	if isUniqueCollectable && uniqueCollectible != ProgressionManager.ProgressionCollectibles.placeholder:
		pass
		#has_unique_collectable() #TODO add unique collectable stuff, basically just get which one it is then ++ on the progressionManager thingimajig
	
	if hasExitAnim && animationPlayer != null:
		var animName: String = get_anim_name()
		
		if animName != null || animName != "":
			animationPlayer.play(animName)
	
	if parent != null || !hasExitAnim:
		if finishedRunning:
			parent.queue_free()

func on_anim_finished(animName: String) -> void:
	if animName == get_anim_name() && get_anim_name() != null || get_anim_name() != "":
		if finishedRunning:
			parent.queue_free()

func get_anim_name() -> String:
	#var animList: Array[String] = get_animation_player_anim_list()
	var animList: PackedStringArray = animationPlayer.get_animation_list()
	var animName: String
	
	if !animList.has("anim_collected"):
		animName = ""
	else:
		var index: int = animList.find("anim_collected", 0)
		animName = animList[index]
	return animName

func has_unique_collectable() -> void:
	match uniqueCollectible:
			ProgressionManager.ProgressionCollectibles.witheredRose:
				print("collected withered rose")
			_:
				print("collected ???")

#func get_animation_player_anim_list() -> Array[String]:
#	#yeah i was tripping some major shit when i thought of this LOL, what the actual fuck is this
#	var animationNames: Array[String] = []
#	
#	if animationPlayer != null:
#		for i in range(animationPlayer.get_state_count()):
#			var animName: String = animationPlayer.get_animation_state_name(i) 
#			animationNames.append(animName)
#	return animationNames
