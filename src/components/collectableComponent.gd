class_name CollectableComponent
extends Area2D

@onready var player: Player = Utils.get_player()

@export var animationPlayer: AnimationPlayer
@export var hasCollectAnim: bool
@export var hasCollectedAnim: bool
@export var hasIdleAnim: bool

@export var collisionShape: CollisionShape2D

@export var isUniqueCollectable: bool
#@export var uniqueCollectible: ProgressionManager.

@export var hasRespawnTimer: bool
@export var respawnTime: float


var respawnTimer: Timer
var pollTimer: Timer

var finishedRunning: bool = false
var playerInside: bool = false

var parent: Node = null

var collectConditions: Array[Callable] = []

var pollCheckInterval: float = 0.1

signal collectableEntered
signal animInvalid(animName: String)

func _ready() -> void:
	animInvalid.connect(on_anim_invalid)
	
	if animationPlayer != null:
		animationPlayer.animation_finished.connect(on_anim_finished)
	
	if hasIdleAnim:
		var animNameIdle: String = get_anim_name("anim_idle")
		
		if animNameIdle != "":
			animationPlayer.play(animNameIdle)
		else:
			animInvalid.emit("anim_idle")
	
	if parent == null:
		parent = get_parent()

func _on_body_entered(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = true
	
	for condition: Callable in collectConditions:
		if !condition.call():
			start_polling_check()
			return
	
	handle_collecting()

func _on_body_exited(body: Node2D) -> void:
	if !body == player || !body is Player:
		return
	
	playerInside = false

func start_polling_check() -> void:
	pollTimer = Timer.new()
	pollTimer.wait_time = pollCheckInterval
	pollTimer.one_shot = false
	pollTimer.timeout.connect(on_poll_timer_finished)
	parent.add_child(pollTimer)
	pollTimer.start()

func on_poll_timer_finished() -> void:
	if !playerInside:
		pollTimer.stop()
		pollTimer.queue_free()
	else:
		for condition: Callable in collectConditions:
			if condition.call():
				pollTimer.stop()
				pollTimer.queue_free()
				handle_collecting()

func handle_collecting() -> void:
	collectableEntered.emit() #connects to parent method to do whatever the parent needs to do when player enters
	
	if animationPlayer == null:
		Utils.debug_print(self, "animationPlayer is: %s", [animationPlayer])
		if finishedRunning:
			parent.queue_free()
	
	#if isUniqueCollectable && uniqueCollectible != ProgressionManager.ProgressionCollectibles.placeholder:
	#	Utils.debug_print(self, "is a unique collectable")
	
	if !hasCollectAnim:
		if finishedRunning:
			parent.queue_free()
		else:
			pass
			#parent.queue_free()
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
			var animNameCollectableOutline: String = get_anim_name("anim_collected")
			
			if animNameCollectableOutline != "":
				animationPlayer.play(animNameCollectableOutline)
			else:
				animInvalid.emit("anim_collected")
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

func add_collect_condition(condition: Callable) -> void:
	collectConditions.append(condition)

func on_anim_invalid(_animName) -> void:
	Utils.debug_print(self, "animation '%s' not found / invalid", [_animName])
