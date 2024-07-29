extends Node2D

@onready var interactionAreaComponent: InteractionAreaComponent = $InteractionAreaComponent


func _ready() -> void:
	interactionAreaComponent.interact = Callable(self, "on_interact")

func on_interact() -> void:
	print("interacteddddd")
