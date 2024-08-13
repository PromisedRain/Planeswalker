extends Node2D

@onready var collectableComponent: CollectableComponent = $CollectableComponent

#TODO make collectable follow after player only to get collected when you clear the level that the collectable was in. for now its just queue free

func _ready() -> void:
	collectableComponent.collectableEntered.connect(on_entered)
	collectableComponent.parentEnterCondition = get_enter_condition()

func on_entered() -> void:
	collectableComponent.finishedRunning = true

func get_enter_condition() -> bool:
	
	return true
