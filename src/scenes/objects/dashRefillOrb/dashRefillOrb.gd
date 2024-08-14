extends Node2D

@onready var player: CharacterBody2D = Utils.get_player()
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var cpuParticles: CPUParticles2D = $CPUParticles2D
@onready var collectableComponent: CollectableComponent = $CollectableComponent

var rotSpeed: float = 0.05

func _ready() -> void:
	turn_on_cpu_particles()
	collectableComponent.collectableEntered.connect(on_entered)
	
	collectableComponent.add_collect_condition(self.get_enter_condition)

func on_entered() -> void:
	player.refill_dashes()
	collectableComponent.finishedRunning = true

func get_enter_condition() -> bool:
	if player.get_total_dashes() < player.maxDashes:
		return true
	else:
		return false

func turn_on_cpu_particles() -> void:
	if !cpuParticles.emitting:
		cpuParticles.emitting = true

func turn_off_cpu_particles() -> void:
	if cpuParticles.emitting:
		cpuParticles.emitting = false
