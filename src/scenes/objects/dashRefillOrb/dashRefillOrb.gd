extends Node2D

@onready var player: CharacterBody2D = Utils.get_player()
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var cpuParticles2D: CPUParticles2D = $CPUParticles2D
@onready var collectableComponent: CollectableComponent = $CollectableComponent

var rotSpeed: float = 0.05

func _ready() -> void:
	if !cpuParticles2D.emitting:
		cpuParticles2D.emitting = true
	
	collectableComponent.collectableEntered.connect(on_entered)

func on_entered() -> void:
	player.refill_dashes()
	collectableComponent.finishedRunning = true
