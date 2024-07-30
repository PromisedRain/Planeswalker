extends CanvasLayer

@onready var player: CharacterBody2D = NodeUtility.get_player()

@onready var staminaBar: TextureProgressBar = $Control/MarginContainer/Stamina/MarginContainer/Control/StaminaBar
@onready var stopwatchLabel: Label = $Control/MarginContainer/Stopwatch/MarginContainer/Control/StopwatchLabel

#vars
var maxStamina: float
var currentStamina: float

var time: float = 0.0
var milliseconds: float = 0.0
var seconds: float = 0.0
var minutes: float = 0.0

func _ready() -> void:
	#init_stamina_bar()
	init_stopwatch_timer()
	
	#player.climbStaminaChanged.connect(on_stamina_changed)

func _process(delta: float) -> void:
	update(delta)

func update(delta: float) -> void:
	#time
	time += delta
	milliseconds = fmod(time, 1) * 1000
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	stopwatchLabel.text = "%03d: %02d. %02d" %[milliseconds, seconds, minutes]
	

func init_stopwatch_timer() -> void:
	stopwatchLabel.text = "000: 00. 00"

func init_stamina_bar() -> void:
	maxStamina = player.climbMaxStamina
	currentStamina = maxStamina
	
	staminaBar.min_value = 0.0
	staminaBar.max_value = maxStamina
	staminaBar.value = currentStamina
	staminaBar.tint_progress = Color("#1c9393") #1c9393

func on_stamina_changed(amount: float) -> void:
	currentStamina = amount
	staminaBar.value = currentStamina
