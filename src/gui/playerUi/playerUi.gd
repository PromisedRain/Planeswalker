extends CanvasLayer

@onready var player: CharacterBody2D = NodeUtility.get_player()
@onready var staminaBar: ProgressBar = $Control/MarginContainer/Stamina/MarginContainer/Control/StaminaBar

#vars
var maxStamina: float
var currentStamina: float

func _ready() -> void:
	init_stamina_bar()
	#signals
	player.climbStaminaChanged.connect(on_stamina_changed)

func _process(delta: float) -> void:
	pass

func init_stamina_bar() -> void:
	maxStamina = player.climbMaxStamina
	currentStamina = maxStamina
	
	staminaBar.min_value = 0.0
	staminaBar.max_value = maxStamina
	staminaBar.value = currentStamina

func on_stamina_changed(amount: float) -> void:
	currentStamina = amount
	staminaBar.value = currentStamina



