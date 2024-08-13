class_name CollectableComponent
extends Area2D

@onready var player: Player = Utils.get_player()

@export_category("animation")
@export var animationPlayer: AnimationPlayer
@export var hasCollectAnim: bool
@export var hasCollectedAnim: bool
@export var hasIdleAnim: bool


@export_category("misc")
@export var collisionShape: CollisionShape2D

@export var isUniqueCollectable: bool
@export var uniqueCollectible: ProgressionManager.ProgressionCollectibles

@export var hasRespawnTimer: bool
@export var respawnTime: float


var respawnTimer: Timer
var parent: Node = null
var finishedRunning: bool = false
var parentEnterCondition: Variant = null

signal collectableEntered
signal animInvalid(animName: String)

func _ready() -> void:
	animInvalid.connect(on_anim_invalid)
	
	if animationPlayer != null:
		animationPlayer.animation_finished.connect(on_anim_finished)
	
	if hasIdleAnim:
		var animNameIdle = get_anim_name("anim_idle")
		
		if animNameIdle != "":
			animationPlayer.play(animNameIdle)
		else:
			animInvalid.emit("anim_idle")
	
	if parent == null:
		parent = get_parent()

func _on_body_entered(body: Node2D) -> void:
	if !body == player || !body is Player:
		if parentEnterCondition != null:
			if parentEnterCondition:
				return
		else:
			return
	
	print("entered collectable %s" % parent.get_name())
	collectableEntered.emit() #connects to parent method to do whatever the parent needs to do when player enters
	
	if animationPlayer == null:
		print("[collectableComponent] Animationplayer is null")
		if finishedRunning:
			parent.queue_free()
	
	if isUniqueCollectable && uniqueCollectible != ProgressionManager.ProgressionCollectibles.placeholder:
		print("[collectableComponent] Is unique collectable")
	
	if !hasCollectAnim:
		if finishedRunning:
			parent.queue_free()
		else:
			await finishedRunning == true
			parent.queue_free()
	else:
		var animNameCollect: String = get_anim_name("anim_collect")
		
		if animNameCollect != "":
			call_deferred("change_collision", true)
			animationPlayer.play(animNameCollect)
			
		else:
			animInvalid.emit("anim_collect")


func change_collision(disable: bool) -> void:
	collisionShape.disabled = disable

func on_anim_finished(animName: String) -> void:
	if animName == get_anim_name("anim_collect") && get_anim_name("anim_collect") != "":
		if !hasRespawnTimer && !respawnTime > 0 && finishedRunning:
			parent.queue_free()
		else:
			var animNameCollectableOutline: String = get_anim_name("anim_collectable_outline")
			
			if animNameCollectableOutline != "":
				animationPlayer.play(animNameCollectableOutline)
			else:
				animInvalid.emit("anim_collectable_outline")
		create_respawn_timer()

func create_respawn_timer() -> void:
	respawnTimer = Timer.new()
	respawnTimer.wait_time = respawnTime
	respawnTimer.timeout.connect(on_respawn_timer_finished)
	parent.add_child(respawnTimer)
	respawnTimer.start()

func on_respawn_timer_finished() -> void:
	respawnTimer.queue_free()
	call_deferred("change_collision", false)
	finishedRunning = false
	var animNameIdle: String = get_anim_name("anim_idle")
	
	if animNameIdle != "":
		animationPlayer.play(animNameIdle)
	else:
		animInvalid.emit("anim_idle")

func get_anim_name(_animName: String) -> String:
	var animList: PackedStringArray = animationPlayer.get_animation_list()
	
	if !animList.has(_animName):
		return ""
	return _animName

func has_unique_collectable() -> void:
	match uniqueCollectible:
			ProgressionManager.ProgressionCollectibles.witheredRose:
				print("collected withered rose")
			_:
				print("collected ???")

func on_anim_invalid(_animName) -> void:
	print("[collectableComponent] Animation '%s' not found/invalid" % _animName)
