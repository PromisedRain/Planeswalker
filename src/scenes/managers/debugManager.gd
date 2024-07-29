extends CanvasLayer

@onready var player = NodeUtility.get_player()

@onready var stateLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/StateLabel
@onready var fpsLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/FpsLabel
@onready var deathsLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer/DeathsLabel

@onready var velocityLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/VelocityLabel
@onready var facingLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/FacingLabel
@onready var directionLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/DirectionLabel
@onready var dashesLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/DashesLabel
@onready var lastDirLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer2/LastDirLabel

@onready var totalDashesSessionLabel: Label = $Control/MarginContainer/Control/HBoxContainer/VBoxContainer3/TotalDashesSessionLabel
  
var time: float = 0.0
var minutes: float = 0.0
var seconds: float = 0.0
var mSec: float = 0.0


func _process(delta: float) -> void:
	stateLabel.text = "state: %s" %player.stateMachine.get_current_state_name()
	var fps = Engine.get_frames_per_second()
	
	fpsLabel.text = "fps: %s" %fps
	deathsLabel.text = "deaths: %s" %str(0)
	
	velocityLabel.text = "velocity: (%s, %s)"  %[str(round(player.velocity.x)), str(round(player.velocity.y))]
	facingLabel.text = "facing: (%s, %s)" %[player.facing.x, player.facing.y]
	directionLabel.text = "dir: (%s, %s)" %[player.direction.x, player.direction.y]
	dashesLabel.text =  "dashes: %s" %player.totalDashes
	lastDirLabel.text = "lastDir: %s" %lastDirection
	
	totalDashesSessionLabel.text = "totalDashesSession: %s" %player.totalDashesSession

var lastDirection: String:
	get:
		match player.lastDir:
			Vector2.RIGHT:
				return "right"
			Vector2.LEFT:
				return "left"
			_:
				return "right"
