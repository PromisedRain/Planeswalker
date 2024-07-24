class_name HealthComponent
extends Node2D

@export var maxHealth: int = 1

var currentHealth: int
var hasDied: bool = false

signal died
signal healthChanged

#TODO

func _ready() -> void:
	init_health()

func init_health() -> void:
	currentHealth = maxHealth

func get_health() -> int:
	return currentHealth

func get_max_health() -> int:
	return maxHealth

func update() -> void:
	if currentHealth < 0:
		currentHealth = 0
	
	if currentHealth <= 0:
		emit_signal("died")
		currentHealth += 1 #testing purposes

func damage(amount: int) -> void:
	currentHealth -= amount
	emit_signal("healthChanged")
	update()

func heal(amount: int) -> void:
	damage(-amount)

