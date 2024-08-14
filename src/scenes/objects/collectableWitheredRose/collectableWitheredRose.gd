extends Node2D

@onready var collectableComponent: CollectableComponent = $CollectableComponent
@onready var player: Player = Utils.get_player()

#TODO make collectable follow after player only to get collected when you clear the level that the collectable was in. for now its just queue free

func _ready() -> void:
	collectableComponent.collectableEntered.connect(on_entered)

func on_entered() -> void:
	collectableComponent.finishedRunning = true
