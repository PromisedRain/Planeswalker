extends CharacterBody2D

#chomps :3

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var healthComponent: Node2D = $HealthComponent
@onready var wallSlideRaycasts = $WallSlideRaycasts

@onready var player: CharacterBody2D = $"."
@onready var body: Sprite2D = $Visuals/Body

#debug
@onready var stateLabel: Label = $CanvasLayer/VBoxContainer/StateLabel
@onready var velocityLabel: Label = $CanvasLayer/VBoxContainer/VelocityLabel
@onready var facingLabel: Label = $CanvasLayer/VBoxContainer/FacingLabel
@onready var directionLabel: Label = $CanvasLayer/VBoxContainer/DirectionLabel
@onready var CanJumpLabel: Label = $CanvasLayer/VBoxContainer/CanJumpLabel


var stateMachine: StateMachine = StateMachine.new()
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var lastDirection: Vector2 = Vector2.RIGHT # last direction you have faced. as in right left.
var direction: Vector2
var facing: Vector2 # specifically for where you can dash; north, west, south, east, nothwest, southeast... - etc.

var canMove: bool = true
var canDash: bool
var canJump: bool
var jumpInput: bool
var dir: Vector2

#movement variables
const speed: float = 68.0
const maxSpeed: float = speed

const groundAcceleration: float = 11.6
const airAcceleration: float = 54.2
const acceleration: float = groundAcceleration
#const halfAcceleration: float = acceleration / 1.5

const groundFriction: float = 58.23
const airResistance: float = 35.5
const friction: float = groundFriction
#const halfFriction: float = friction / 1.5

const jumpSpeed: float = -275.0 # how high you jump
const variableJumpHeightMultiplier: float = 0.43 #variable jump height multiplier when you release jump button.
const fallSpeed: float = 250.0
const maxFallSpeed: float = fallSpeed 

const gravityScale: float = 1.15
const gravityStFallScale: float = 1.15

func _ready() -> void:
	var states = ["idle", "move", "jump", "fall", "dash", "slide", "duck"]
	
	for state in states:
		stateMachine.add_states(
			state,
			Callable(self, "st_%s" % state),
			Callable(self, "st_enter_%s" % state),
			Callable(self, "st_leave_%s" % state)
		)
	stateMachine.set_initial_state(Callable(self, "st_idle"))
	
	#other stuff
	healthComponent.connect("died", on_dead)

func _physics_process(delta: float) -> void:
	stateMachine.update(delta)
	if canMove:
		player_input()
	
	move_and_slide()
	
	# debug
	stateLabel.text = stateMachine.get_current_state_name()
	velocityLabel.text = "velocity: " + "(" + str(velocity.x) + "," + str(velocity.y) + ")"
	facingLabel.text = "facing: " + "(" + str(facing.x) + ", " + str(facing.y) + ")"
	directionLabel.text = "direction: " + "(" + str(direction.x) + ", " + str(direction.y) + ")"
	CanJumpLabel.text = "can jump: " + str(canJump)


func _gravity_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * gravityScale * delta
	elif stateMachine.get_current_state() == Callable(self, "st_fall"):
		velocity.y = gravity * gravityStFallScale * delta 

func player_input() -> void:
	facing = Vector2.ZERO
	direction = Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		facing.x += 1
		direction = Vector2.RIGHT
		body.flip_h = false
	if Input.is_action_pressed("left"):
		facing.x -= 1
		direction = Vector2.LEFT
		body.flip_h = true
	if Input.is_action_pressed("down"):
		facing.y += 1
	if Input.is_action_pressed("up"):
		facing.y -= 1
	
	jumpInput = Input.is_action_just_pressed("jump")

func player_movement(delta) -> void:
	if direction != Vector2.ZERO:
		#print(direction)
		if !is_on_floor():
			accelerate_in_direction(direction, delta, true)
			print("in air")
		else:
			accelerate_in_direction(direction, delta)
	else:
		if !is_on_floor():
			decelerate(delta, true)
		else:
			decelerate(delta)

func accelerate_in_direction(direction: Vector2, delta: float, air: bool = false) -> void:
	var accel: float = acceleration
	if air:
		accel = airAcceleration
	to_velocity(Vector2(direction.x * maxSpeed, velocity.y), accel, delta)

func decelerate(delta: float, air: bool = false) -> void:
	var fric: float = friction
	if air:
		fric = airResistance
	to_velocity(Vector2(0, velocity.y), fric, delta)

func to_velocity(to: Vector2, weight: float, delta: float) -> void:
	velocity = lerp(velocity, to, weight * delta)

func get_direction_next_to_wall() -> Vector2:
	for raycast: RayCast2D in wallSlideRaycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return Vector2()

#states

#idle
func st_idle(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if velocity.x != 0:
		return Callable(self, "st_move")
	if jumpInput && canJump:
		return Callable(self, "st_jump")
	if velocity.y > 0:
		return Callable(self, "st_fall")
	return Callable()

func st_enter_idle() -> void:
	animationPlayer.play("anim_idle")
	canJump = true
	print("entering idle")

func st_leave_idle() -> void:
	print("leaving idle")

#move
func st_move(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if velocity.x == 0:
		return Callable(self, "st_idle")
	if jumpInput:
		return Callable(self, "st_jump")
	if velocity.y > 0:
		return Callable(self, "st_fall")
	return Callable()

func st_enter_move() -> void:
	pass

func st_leave_move() -> void:
	pass

#jump
func st_jump(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if Input.is_action_just_released("jump"): # specifically for variable jump height
		velocity.y *= variableJumpHeightMultiplier 
	
	if velocity.y > 0:
		return Callable(self, "st_fall")
	return Callable()

func st_enter_jump() -> void:
	velocity.y = jumpSpeed
	canJump = false

func st_leave_jump() -> void:
	print("leaving jump")

#fall
func st_fall(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if is_on_floor():
		return Callable(self, "st_idle")
	if jumpInput && canJump:
		return Callable(self, "st_jump")
	return Callable()

func st_enter_fall() -> void:
	print("entering fall")

func st_leave_fall() -> void:
	print("leaving fall")

#dash
func st_dash(delta: float) -> Callable:
	return Callable()

func st_enter_dash() -> void:
	pass

func st_leave_dash() -> void:
	pass

#slide(walls)
func st_slide(delta: float) -> Callable:
	return Callable()

func st_enter_slide() -> void:
	pass

func st_leave_slide() -> void:
	pass

#duck
func st_duck() -> Callable:
	return Callable()

func st_enter_duck() -> void:
	pass

func st_leave_duck() -> void:
	pass


func on_dead() -> void:
	pass

