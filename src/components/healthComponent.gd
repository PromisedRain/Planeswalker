class_name HealthComponent
extends Node2D

@export var maxHealth: int = 1

var currentHealth: int
var hasDied: bool = false

signal died
signal healthChanged

#TODO

func _ready():
	init_health()

func init_health():
	currentHealth = maxHealth

func get_health():
	return currentHealth

func get_max_health():
	return maxHealth

func update():
	if currentHealth < 0:
		currentHealth = 0
	
	if currentHealth <= 0:
		emit_signal("died")
		currentHealth += 1 #testing purposes

func damage(amount: float):
	currentHealth -= amount
	emit_signal("healthChanged")
	update()

func heal(amount: float):
	damage(-amount)

