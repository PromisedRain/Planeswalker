extends Node2D

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var collectableComponent: CollectableComponent = $CollectableComponent

#TODO make collectable follow after player only to get collected when you clear the level that the collectable was in. for now its just queue free

func _ready() -> void:
	animationPlayer.play("anim_idle")
	collectableComponent.collectableEntered.connect(on_entered)

func on_entered() -> void:
	collectableComponent.finishedRunning = true
