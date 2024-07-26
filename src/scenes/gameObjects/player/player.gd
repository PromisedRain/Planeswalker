extends CharacterBody2D
#lilith

@onready var sprite: Sprite2D = $Visuals/Body
@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var healthComponent: HealthComponent = $HealthComponent
@onready var wallSlideRaycasts = $WallSlideRaycasts
@onready var normalCollisionBox: CollisionShape2D = $NormalCollisionBox
@onready var duckedCollisionBox: CollisionShape2D = $DuckCollisionBox
@onready var dashTrailLine: Line2D = $DashTrailLine
@onready var dashParticles: CPUParticles2D = $DashParticles
@onready var dashGhost: PackedScene = preload("res://src/components/dashGhostComponent.tscn")


#vars
var stateMachine: StateMachine
var direction: Vector2
var lastDir: Vector2 = Vector2.RIGHT
var facing: Vector2

var dead: bool = false

var respawn: bool = false
var respawnTimer: float
var justRespawned: bool

var jumpInput: bool
var jumpGraceTimer: float = 0.0 
var jumpBufferTimer: float = 0.0
var canJump: bool
var jumpBuffer: bool
var isJumping: bool = false

var dashInput: bool 
var dashCooldownTimer: float
var dashLengthTimer: float
var dashTrailTimer: float
var dashDir: Vector2
var beforeDashSpeed: Vector2
var isDashing: bool = false
var totalDashes: int
var totalDashesSession: int
var dashStartedOnGround: bool
var duckInput: bool

#constants
const dashSpeed: float = 240.0
const endDashSpeed: float = 160.0
const dashLengthTime: float = 0.135
const dashTrailTime: float = 0.04
const ghostDashColor: Color = Color("#5694ff")
const dashCooldownTime: float = 0.35
const maxDashes: int = 1

const runSpeed: float = 90.0
const maxRunSpeed: float = runSpeed
const runAccel: float = 12.0
const airAccel: float = 10.5

const groundFriction: float = 35.0
const airResistance: float = 32.0
const friction: float = groundFriction
const duckFriction: float = friction / 1.5

const jumpHeight: float = (210.0) * -1 
const jumpHBoost: float = 0.925
const jumpAirHang: float = 0.8
const jumpGraceTime: float = 0.19
const jumpBufferTime: float = 0.11
const variableJumpH: float = 0.45 

const fallGravity: float = 1.15
const fallSpeed: float = 310.0
const maxFallSpeed: float = fallSpeed 
const gravity: int = 900

const bodySquashStretchReversion: float = 1.75
const bodySquashVec: Vector2 = Vector2(1.4, 0.8)
const bodyStretchVec: Vector2 = Vector2(0.6, 1.4) 
const bodyDuckSquashVec: Vector2 = Vector2(1.4, 0.8)

const respawnTime: float = 2.5

func _ready() -> void:
	
	stateMachine = StateMachine.new()
	stateMachine.add_states("idle", Callable(self, "st_idle"), Callable(self, "st_enter_idle"), Callable(self, "st_leave_idle"))
	stateMachine.add_states("move", Callable(self, "st_move"), Callable(self, "st_enter_move"), Callable(self, "st_leave_move"))
	stateMachine.add_states("jump", Callable(self, "st_jump"), Callable(self, "st_enter_jump"), Callable(self, "st_leave_jump"))
	stateMachine.add_states("fall", Callable(self, "st_fall"), Callable(self, "st_enter_fall"), Callable(self, "st_leave_fall"))
	stateMachine.add_states("dash", Callable(self, "st_dash"), Callable(self, "st_enter_dash"), Callable(self, "st_leave_dash"))
	stateMachine.add_states("slide", Callable(self, "st_slide"), Callable(self, "st_enter_slide"), Callable(self, "st_leave_slide"))
	stateMachine.add_states("duck", Callable(self, "st_duck"), Callable(self, "st_enter_duck"), Callable(self, "st_leave_duck"))
	stateMachine.add_states("respawn", Callable(self, "st_respawn"), Callable(self, "st_enter_respawn"), Callable(self, "st_leave_respawn"))
	stateMachine.add_states("dead", Callable(self, "st_dead"), Callable(self, "st_enter_dead"), Callable(self, "st_leave_dead"))
	stateMachine.set_initial_state(Callable(self, "st_idle"))
	
	healthComponent.connect("died", Callable(self, "st_dead"))
	start_jump_buffer_timer()

# physics
func _physics_process(delta: float) -> void:
	stateMachine.update(delta)
	update(delta)
	if canControl:
		facing = Vector2.ZERO
		direction = Vector2.ZERO
		player_input()
		move_and_slide()

func start_jump_grace_timer():
	jumpGraceTimer = jumpGraceTime

func start_jump_buffer_timer():
	jumpBufferTimer = jumpBufferTime

#acceleration and friction
func apply_velocity(to: Vector2, weight: float, delta: float) -> void:
	velocity = lerp(velocity, to, weight * delta)

func accelerate(dir: Vector2, delta: float, air: bool = false) -> void:
	var acceleration: float = runAccel
	if air:
		acceleration = airAccel
	apply_velocity(Vector2(dir.x * maxRunSpeed, velocity.y), acceleration, delta)

func decelerate(delta: float, air: bool = false) -> void:
	var fric: float = friction
	if air:
		fric = airResistance
	apply_velocity(Vector2(0, velocity.y), fric, delta)

func _gravity_process(delta: float) -> void:
	if !is_on_floor():
		if velocity.y >= 0:
			velocity.y += gravity * jumpAirHang * delta
		else:
			velocity.y += gravity * jumpHBoost * delta
	elif stateMachine.currentState == Callable(self, "st_fall"):
		velocity.y += gravity * fallGravity * delta
	
	if velocity.y > maxFallSpeed:
		velocity.y = maxFallSpeed

func update(delta: float) -> void:
	# dash
	if dashCooldownTimer > 0.0:
		dashCooldownTimer -= delta
	
	if dashLengthTimer > 0.0:
		dashLengthTimer -= delta
	if NodeUtility.is_approximately_equal(dashLengthTimer, 0.0, 0.01):
		isDashing = false
	
	#jump
	if jumpGraceTimer > 0.0:
		jumpGraceTimer -= delta
	if NodeUtility.is_approximately_equal(jumpGraceTimer, 0.0, 0.01):
		canJump = false
	
	if jumpBufferTimer > 0.0:
		jumpBufferTimer -= delta
	if NodeUtility.is_approximately_equal(jumpBufferTimer, 0.0, 0.01):
		jumpBuffer = false
	
	#respawn
	if respawnTimer > 0.0:
		respawnTimer -= delta
	if NodeUtility.is_approximately_equal(respawnTimer, 0.0, 0.01):
		respawn = true
	
	if justRespawned && (velocity != Vector2.ZERO):
		justRespawned = false
	
	#sprite
	update_sprite(delta)

func update_sprite(delta: float) -> void:
	# scale tweening
	sprite.scale.x = move_toward(sprite.scale.x, 1.0, bodySquashStretchReversion * delta)
	sprite.scale.y = move_toward(sprite.scale.y, 1.0, bodySquashStretchReversion * delta)
	
	#anims
	if canControl && !sequenceState:
		
		#idle
		if stateMachine.currentState == Callable(self, "st_idle"):
			animationPlayer.play("anim_idle")
		
		#move
		elif stateMachine.currentState == Callable(self, "st_move"):
			animationPlayer.play("anim_run")
		
		#jump
		elif stateMachine.currentState == Callable(self, "st_jump"):
			animationPlayer.play("anim_jump")
		
		#fall
		elif stateMachine.currentState == Callable(self, "st_fall"):
			animationPlayer.play("anim_jump")
		
		#dash
		elif stateMachine.currentState == Callable(self, "st_dash"):
			pass
		
		#duck
		elif stateMachine.currentState == Callable(self, "st_duck"):
			animationPlayer.play("anim_duck")

# inputs
func player_input() -> void:
	if Input.is_action_pressed("right"):
		facing.x += 1
		direction = Vector2.RIGHT
		sprite.flip_h = false
	if Input.is_action_pressed("left"):
		facing.x -= 1
		direction = Vector2.LEFT
		sprite.flip_h = true
	if Input.is_action_pressed("down"):
		facing.y += 1
	if Input.is_action_pressed("up"):
		facing.y -= 1
	
	jumpInput = Input.is_action_just_pressed("jump")
	
	dashInput = Input.is_action_just_pressed("dash")
	
	duckInput = Input.is_action_pressed("duck")

func refill_dashes() -> bool:
	if totalDashes < maxDashes:
		totalDashes = maxDashes
		return true
	else:
		return false

func player_movement(delta) -> void:
	if direction != Vector2.ZERO:
		if !is_on_floor():
			accelerate(direction, delta, true)
		else:
			accelerate(direction, delta)
	else:
		if !is_on_floor():
			decelerate(delta, true)
		else:
			if velocity.x != 0:
				decelerate(delta)

#idle
func st_idle(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	canJump = true
	
	if !NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move")
	
	if (jumpInput || jumpBuffer) && canJump:
		jumpBuffer = false
		return Callable(self, "st_jump")
	
	if velocity.y > 0:
		return Callable(self, "st_fall")
	
	if canDash:
		return Callable(self, "st_dash")
	
	if duckInput:
		return Callable(self, "st_duck")
	
	return Callable()

func st_enter_idle(delta: float = 0) -> void:
	canJump = true
	
	if stateMachine.previousState == Callable(self, "st_fall"):
		sprite.scale = bodySquashVec
	
	refill_dashes()

func st_leave_idle(delta: float = 0) -> void:
	pass

#move
func st_move(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_idle")
	
	if jumpInput || jumpBuffer:
		jumpBuffer = false
		return Callable(self, "st_jump")
	
	if velocity.y > 0:
		return Callable(self, "st_fall")
	
	if canDash: 
		return Callable(self, "st_dash")
	
	if duckInput:
		return Callable(self, "st_duck")
	
	return Callable()

func st_enter_move(delta: float = 0) -> void:
	if stateMachine.previousState == Callable(self, "st_fall"):
		sprite.scale = bodySquashVec
	
	refill_dashes()

func st_leave_move(delta: float = 0) -> void:
	pass

#jump
func st_jump(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if jumpInput:
		jumpBuffer = true
		start_jump_buffer_timer()
	
	# variable jump height
	if Input.is_action_just_released("jump"): 
		velocity.y *= variableJumpH 
	
	if velocity.y >= 0:
		return Callable(self, "st_fall")
	
	if canDash: 
		return Callable(self, "st_dash")
	
	return Callable()

func st_enter_jump(delta: float = 0) -> void:
	sprite.scale = bodyStretchVec
	velocity.y = jumpHeight
	canJump = false

func st_leave_jump(delta: float = 0) -> void:
	pass

#fall
func st_fall(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if is_on_floor() && !NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move")
	
	if is_on_floor():
		return Callable(self, "st_idle")
	
	if (jumpInput || jumpBuffer) && canJump:
		return Callable(self, "st_jump")
	
	if canDash: 
		return Callable(self, "st_dash")
	
	return Callable()

func st_enter_fall(delta: float = 0) -> void:
	if stateMachine.previousState == Callable(self, "st_idle") || stateMachine.previousState == Callable(self, "st_move") || stateMachine.previousState == Callable(self, "st_slide"):
		canJump = true
		start_jump_grace_timer()
	else:
		canJump = false
	start_jump_grace_timer()

func st_leave_fall(delta: float = 0) -> void:
	pass

#dash
func st_dash(delta: float) -> Callable:
	
	if dashTrailTimer > 0:
		dashTrailTimer -= delta
		if dashTrailTimer <= 0:
			create_dash_trail()
			dashTrailTimer = dashTrailTime
	
	if !isDashing:
		return Callable(self, "st_fall")
	
	if jumpInput && canJump:
		return Callable(self, "st_jump")
	
	return Callable()

func create_dash_trail() -> void:
	var ghostInstance: Sprite2D = dashGhost.instantiate()
	ghostInstance.texture = sprite.texture
	ghostInstance.hframes = sprite.hframes
	ghostInstance.global_position = sprite.global_position
	ghostInstance.flip_h = sprite.flip_h
	ghostInstance.modulate = ghostDashColor
	get_parent().add_child(ghostInstance)

func st_enter_dash(delta: float = 0) -> void:
	totalDashes = max(0, totalDashes - 1)
	isDashing = true
	dashParticles.emitting = true
	
	dashLengthTimer = dashLengthTime
	dashCooldownTimer = dashCooldownTime
	dashTrailTimer = dashTrailTime
	
	if facing != Vector2.ZERO:
		dashDir = facing
	else:
		dashDir = lastDir
	
	dashParticles.direction = dashDir.normalized()
	velocity = dashDir.normalized() * dashSpeed

func st_leave_dash(delta: float = 0) -> void:
	leave_dash_events()
	isDashing = false
	dashTrailTimer = 0
	dashParticles.emitting = false

func leave_dash_events() -> void:
	totalDashesSession += 1

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
		apply_velocity(Vector2(0, velocity.y), duckFriction, delta)
	
	if velocity.y > 0:
		return Callable(self, "st_fall")
	
	if !duckInput:
		return Callable(self, "st_idle")
	
	if jumpInput && canJump:
		return Callable(self, "st_jump")
	
	return Callable()

func st_enter_duck(delta: float = 0) -> void:
	sprite.scale = bodyDuckSquashVec
	
	duckedCollisionBox.disabled = false
	normalCollisionBox.disabled = true

func st_leave_duck(delta: float = 0) -> void:
	duckedCollisionBox.disabled = true
	normalCollisionBox.disabled = false

#respawn
func st_respawn(delta: float) -> void:
	return Callable()

func st_enter_respawn(delta: float = 0) -> void:
	pass

func st_leave_respawn(delta: float = 0) -> void:
	pass

#dead
func st_dead(delta: float) -> void:
	return Callable()

func st_enter_dead(delta: float = 0) -> void:
	pass

func st_leave_dead(delta: float = 0) -> void:
	pass

# getters
func can_dash() -> bool:
	return dashInput && dashCooldownTimer <= 0.0 && totalDashes > 0

var canDash: bool:
	get:
		return can_dash()

func can_control() -> bool:
	match stateMachine.currentState:
		"st_respawn":
			return false
		"st_dead":
			return false
		_:
			return true

var canControl: bool:
	get:
		return can_control()

func sequence_state() -> bool:
	match stateMachine.currentState:
		"st_respawn":
			return true
		"st_dead":
			return true
		_:
			return false

var sequenceState: bool:
	get:
		return sequence_state()

func get_direction_next_to_wall() -> Vector2:
	for raycast: RayCast2D in wallSlideRaycasts:
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return Vector2()

#func get_debug_trail_color() -> Color:
#	match stateMachine.currentState:
#		"st_idle":
#			return Color.WHITE
#		"st_move":
#			return Color.AQUA
#		"st_jump":
#			return Color.DARK_RED
#		"st_fall":
#			return Color.DIM_GRAY
#		"st_dash":
#			return Color.PURPLE
#		"st_slide":
#			return Color.CORNFLOWER_BLUE
#		"st_duck":
#			return Color.DARK_ORANGE
#		"st_respawn":
#			return Color.CRIMSON
#		"st_dead":
#			return Color.BLACK
#		_:
#			return Color.WHITE
