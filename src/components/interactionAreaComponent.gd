class_name InteractionAreaComponent
extends Area2D

@export var action: String = "Interact"

var interact: Callable = func():
	pass


func _on_body_entered(body):
	InteractionManager.register_area(self)


func _on_body_exited(body):
	InteractionManager.register_area(self)
