extends CharacterBody2D

@onready var player: CharacterBody2D = $"."

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var healthComponent: Node2D = $HealthComponent
@onready var wallSlideRaycasts = $WallSlideRaycasts
@onready var normalCollisionBox: CollisionShape2D = $NormalCollisionBox
@onready var duckedCollisionBox: CollisionShape2D = $DuckCollisionBox

@onready var body: Sprite2D = $Visuals/Body

@onready var coyoteTimer: Timer = $CoyoteTimer
@onready var jumpBufferTimer: Timer = $JumpBufferTimer

#debug
@onready var stateLabel: Label = $CanvasLayer/VBoxContainer/StateLabel
@onready var velocityLabel: Label = $CanvasLayer/VBoxContainer/VelocityLabel
@onready var facingLabel: Label = $CanvasLayer/VBoxContainer/FacingLabel
@onready var directionLabel: Label = $CanvasLayer/VBoxContainer/DirectionLabel
@onready var CanJumpLabel: Label = $CanvasLayer/VBoxContainer/CanJumpLabel


var stateMachine: StateMachine = StateMachine.new()
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var lastDirection: Vector2 = Vector2.RIGHT # last direction you have faced. as in right left...
var direction: Vector2
var facing: Vector2 # specifically for where you can dash; north, west, south, east, nothwest, southeast... 

var canMove: bool = true
var canDash: bool
var canJump: bool
var jumpBuffer: bool = false
var jumpInput: bool
var duckInput: bool
var isJumping: bool = false
var isZeroGravity: bool = false

#timers
var coyoteTimerDuration: float = 0.16
var jumpBufferTimerDuration: float = 0.1
var jumpAirHangTimerDuration: float 

#movement variables
var speed: float = 90.0
var maxSpeed: float = speed

var groundAcceleration: float = 9.0 #11.6
var airAcceleration: float = 10.5
var acceleration: float = groundAcceleration
#var halfAcceleration: float = acceleration / 1.5

var groundFriction: float = 35.0 #58.0 #10 #58.23
var airResistance: float = 32.0 # when you dont input while in air
var friction: float = groundFriction
var halfFriction: float = friction / 1.5

#var jumpTimeToDescent: float
#var jumpTimeToPeak: float

#var jumpVelocity: float = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
#var jumpGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
#var fallGravity: float = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0

var variableJumpHeightValue: float = 0.45 #variable jump height multiplier when you release jump button.

var fallSpeed: float = 412.0
var maxFallSpeed: float = fallSpeed 

var jumpHeight: float = (220.0) * -1 #(12750.0) * -1 #
var jumpGravity: float = 0.95
var fallGravity: float = 1.17

# airtime/hangtime when at peak of a jump
var currentHangingTime: float = 0.0
var maxHangingTime: float = 0.02 #0.01

# for the player jump stretch reversion, higher value = faster, lower = slower
var bodySquashStretchReversion: float = 1.0 

var bodySquashValue: Vector2 = Vector2(1.125, 0.8)
var bodyStretchValue: Vector2 = Vector2(0.8, 1.115)
var bodyDuckSquashValue: Vector2 = Vector2(1.15, 0.9)

#lilith

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
	
	jumpBufferTimer.start()
	#other stuff
	healthComponent.connect("died", on_dead)

func _physics_process(delta: float) -> void:
	stateMachine.update(delta)
	if canMove:
		player_input()
	
	move_and_slide()
	
	body.scale.x = move_toward(body.scale.x, 1.0, bodySquashStretchReversion * delta)
	body.scale.y = move_toward(body.scale.y, 1.0, bodySquashStretchReversion * delta)
	
	# debug
	stateLabel.text = stateMachine.get_current_state_name()
	velocityLabel.text = "velocity: " + "(" + str(velocity.x) + "," + str(velocity.y) + ")"
	facingLabel.text = "facing: " + "(" + str(facing.x) + ", " + str(facing.y) + ")"
	directionLabel.text = "direction: " + "(" + str(direction.x) + ", " + str(direction.y) + ")"
	CanJumpLabel.text = "can jump: " + str(canJump)
	#print(velocity.x)

func _gravity_process(delta: float) -> void:
	#if !is_on_floor():
	#	velocity.y += gravity * jumpGravity * delta
	#elif stateMachine.get_current_state() == Callable(self, "st_fall"):
	#	velocity.y = gravity * fallGravity * delta 
	
	#if !is_on_floor():
	#	velocity.y += gravity * delta * (jumpGravity if velocity.y < 0 else fallGravity)
	
	if isZeroGravity:
		velocity.y = 0.0
	else:
		if !is_on_floor():
			velocity.y += gravity * delta * (jumpGravity if velocity.y < 0 else fallGravity)
	
	if velocity.y > maxFallSpeed:
		velocity.y = maxFallSpeed

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
	duckInput = Input.is_action_pressed("duck")
	
	if jumpInput:
		
		jumpBuffer = true
		jumpBufferTimer.start(jumpBufferTimerDuration)

func player_movement(delta) -> void:
	if direction != Vector2.ZERO:
		if !is_on_floor():
			accelerate_in_direction(direction, delta, true)
		else:
			accelerate_in_direction(direction, delta)
	else:
		if !is_on_floor():
			decelerate(delta, true)
		else:
			if velocity.x != 0:
				decelerate(delta)


func accelerate_in_direction(dir: Vector2, delta: float, air: bool = false) -> void:
	var accel: float = acceleration
	if air:
		accel = airAcceleration
	to_velocity(Vector2(dir.x * maxSpeed, velocity.y), accel, delta)

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

func is_approximately_equal(a: float, b: float, epsilon: float = 0.01) -> bool:
	return abs(a - b) < epsilon

#states

#idle
func st_idle(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	canJump = true
	
	if !is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move")
	if (jumpInput || jumpBuffer) && canJump:
		jumpBuffer = false
		return Callable(self, "st_jump")
	if velocity.y > 0:
		return Callable(self, "st_fall")
	if duckInput:
		return Callable(self, "st_duck")
	return Callable()

func st_enter_idle(delta: float = 0) -> void:
	animationPlayer.play("anim_idle")
	canJump = true
	#print("entering idle")
	
	if stateMachine.previousState == Callable(self, "st_fall"):
		body.scale = bodySquashValue

func st_leave_idle(delta: float = 0) -> void:
	pass
	#print("leaving idle")

#move
func st_move(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_idle")
	if jumpInput || jumpBuffer:
		jumpBuffer = false
		return Callable(self, "st_jump")
	if velocity.y > 0:
		return Callable(self, "st_fall")
	if duckInput:
		return Callable(self, "st_duck")
	return Callable()

func st_enter_move(delta: float = 0) -> void:
	animationPlayer.play("anim_run")
	
	if stateMachine.previousState == Callable(self, "st_fall"):
		body.scale = bodySquashValue

func st_leave_move(delta: float = 0) -> void:
	pass

#jump
func st_jump(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if Input.is_action_just_released("jump"): # specifically for variable jump height
		velocity.y *= variableJumpHeightValue 
	
	if velocity.y >= 0:
		if currentHangingTime > maxHangingTime: # hang time
			isZeroGravity = false
			return Callable(self, "st_fall")
		else:
			currentHangingTime += delta
			#print("is hanging, duration left: %s" % currentHangingTime)
			isZeroGravity = true
	else:
		isZeroGravity = false
	
	return Callable()

func st_enter_jump(delta: float = 0) -> void:
	animationPlayer.play("anim_jump")
	body.scale = bodyStretchValue
	velocity.y = jumpHeight #* delta
	canJump = false
	#print(velocity.y)

func st_leave_jump(delta: float = 0) -> void:
	pass
	#print("leaving jump")

#fall
func st_fall(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if is_on_floor() && !is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move")
	if is_on_floor():
		return Callable(self, "st_idle")
	if (jumpInput || jumpBuffer) && canJump:
		return Callable(self, "st_jump")
	return Callable()

func st_enter_fall(delta: float = 0) -> void:
	animationPlayer.play("anim_jump")
	#print("entering fall")
	currentHangingTime = 0.0
	
	if stateMachine.previousState == Callable(self, "st_idle") || stateMachine.previousState == Callable(self, "st_move") || stateMachine.previousState == Callable(self, "st_slide"):
		canJump = true
		coyoteTimer.start(coyoteTimerDuration)
	else:
		canJump = false
	coyoteTimer.start(coyoteTimerDuration)

func st_leave_fall(delta: float = 0) -> void:
	pass
	#print("leaving fall")



#dash
func st_dash(delta: float) -> Callable:
	return Callable()

func st_enter_dash(delta: float = 0) -> void:
	pass

func st_leave_dash(delta: float = 0) -> void:
	pass

#slide
func st_slide(delta: float) -> Callable:
	return Callable()

func st_enter_slide(delta: float = 0) -> void:
	pass

func st_leave_slide(delta: float = 0) -> void:
	pass

#duck
func st_duck(delta: float) -> Callable:
	_gravity_process(delta)
	canJump = true
	jumpInput = Input.is_action_just_pressed("jump")
	
	if velocity.x != 0:
		var fric: float = halfFriction
		to_velocity(Vector2(0, velocity.y), fric, delta)
	
	if velocity.y > 0:
		return Callable(self, "st_fall")
	if !duckInput:
		return Callable(self, "st_idle")
	if jumpInput && canJump:
		return Callable(self, "st_jump")
	return Callable()

func st_enter_duck(delta: float = 0) -> void:
	animationPlayer.play("anim_duck")
	body.scale = bodyDuckSquashValue
	
	duckedCollisionBox.disabled = false
	normalCollisionBox.disabled = true

func st_leave_duck(delta: float = 0) -> void:
	duckedCollisionBox.disabled = true
	normalCollisionBox.disabled = false

func on_dead() -> void:
	pass

func _on_coyote_timer_timeout() -> void:
	canJump = false

func _on_jump_buffer_timer_timeout() -> void:
	jumpBuffer = false

