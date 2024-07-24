extends CanvasLayer

@onready var player = NodeUtility.get_player()

@onready var stateLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/StateLabel
@onready var fpsLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/FpsLabel
@onready var deathsLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/DeathsLabel

@onready var velocityLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/VelocityLabel
@onready var facingLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/FacingLabel
@onready var directionLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/DirectionLabel
@onready var testLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/TestLabel

@onready var timeElapsedLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer3/Control/TimeElapsedLabel
@onready var mSecLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer3/Control/MSecLabel
@onready var secondsLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer3/Control/SecondsLabel
@onready var minutesLabel = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer3/Control/MinutesLabel




var time: float = 0.0
var minutes: float = 0.0
var seconds: float = 0.0
var mSec: float = 0.0

func _process(delta):
	stateLabel.text = "state: %s" %player.stateMachine.get_current_state_name()
	var fps = Engine.get_frames_per_second()
	fpsLabel.text = "fps: %s" %fps
	deathsLabel.text = "deaths: %s" %str(0)
	
	velocityLabel.text = "velocity: (%s, %s)"  %[str(round(player.velocity.x)), str(round(player.velocity.y))]
	facingLabel.text = "facing: (%s, %s)" %[player.facing.x, player.facing.y]
	directionLabel.text = "dir: (%s, %s)" %[player.direction.x, player.direction.y]
	#testLabel.text = 
	
	time += delta
	mSec = fmod(time, 1) * 100
	seconds = fmod(time, 60)
	minutes = fmod(time, 3600) / 60
	minutesLabel.text = "%02d" % minutes
	secondsLabel.text = "%02d." % seconds
	mSecLabel.text = "%03d" % mSec 

