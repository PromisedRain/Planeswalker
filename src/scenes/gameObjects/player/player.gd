extends CharacterBody2D
#lilith

@onready var sprite: Sprite2D = $Visuals/Body
@onready var main: Node = NodeUtility.get_main()

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var healthComponent: HealthComponent = $HealthComponent

@onready var climbWallRaycasts: Node2D = $ClimbWallRaycasts
@onready var climbLedgeGrabTopRaycasts: Array = [$ClimbLedgeGrabRaycasts/TopLeft, $ClimbLedgeGrabRaycasts/TopRight]
@onready var climbLedgeGrabMiddleRaycasts: Array = [$ClimbLedgeGrabRaycasts/MiddleLeft, $ClimbLedgeGrabRaycasts/MiddleRight]

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

var climbInput: bool
var climbStamina: float

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

const upwardCornerCorrection: int = 4
const respawnTime: float = 2.5

const jumpHeight: float = (215.0) * -1 
const jumpHBoost: float = 0.925
const jumpAirHang: float = 0.8
const jumpGraceTime: float = 0.19
const jumpBufferTime: float = 0.11
const variableJumpH: float = 0.45 

const dashSpeed: float = 240.0
const endDashSpeed: float = 160.0
const dashLengthTime: float = 0.13
const dashTrailTime: float = 0.04
const ghostDashColor: Color = Color.DIM_GRAY
const dashCooldownTime: float = 0.35
const maxDashes: int = 1
const dashCornerCorrection: int = 4

const runSpeed: float = 90.0
const maxRunSpeed: float = runSpeed
const runAccel: float = 24.0
const airAccel: float = 16.5

const groundFriction: float = 35.0
const airResistance: float = 70.0
const friction: float = groundFriction
const duckFriction: float = friction / 1.75

const climbFriction: float = 0.86
const climbUpSpeed: float = -46.0
const climbDownSpeed: float = 82.0
const climbJumpHeight: float = maxRunSpeed + jumpHBoost
const climbMaxStamina: float = 7.0
const climbJumpStaminaDrain: float = 1.25
const climbUpStaminaDrain: float = 0.18

const fallGravity: float = 1.15
const fallSpeed: float = 310.0
const maxFallSpeed: float = fallSpeed 
const gravity: int = 900

const bodySquashStretchReversion: float = 1.75
const bodySquashVec: Vector2 = Vector2(1.4, 0.8) #0.6
const bodyStretchVec: Vector2 = Vector2(0.6, 1.4) 
const bodyDuckSquashVec: Vector2 = Vector2(1.4, 0.8) #0.6

#others

enum climbStaminaActions {
	jump,
	climbUp
}

func _ready() -> void:
	stateMachine = StateMachine.new()
	stateMachine.add_states("idle", Callable(self, "st_idle_update"), Callable(self, "st_enter_idle"), Callable(self, "st_leave_idle"))
	stateMachine.add_states("move", Callable(self, "st_move_update"), Callable(self, "st_enter_move"), Callable(self, "st_leave_move"))
	stateMachine.add_states("jump", Callable(self, "st_jump_update"), Callable(self, "st_enter_jump"), Callable(self, "st_leave_jump"))
	stateMachine.add_states("fall", Callable(self, "st_fall_update"), Callable(self, "st_enter_fall"), Callable(self, "st_leave_fall"))
	stateMachine.add_states("dash", Callable(self, "st_dash_update"), Callable(self, "st_enter_dash"), Callable(self, "st_leave_dash"))
	stateMachine.add_states("climb", Callable(self, "st_climb_update"), Callable(self, "st_enter_climb"), Callable(self, "st_leave_climb"))
	stateMachine.add_states("duck", Callable(self, "st_duck_update"), Callable(self, "st_enter_duck"), Callable(self, "st_leave_duck"))
	stateMachine.add_states("respawn", Callable(self, "st_respawn_update"), Callable(self, "st_enter_respawn"), Callable(self, "st_leave_respawn"))
	stateMachine.add_states("dead", Callable(self, "st_dead_update"), Callable(self, "st_enter_dead"), Callable(self, "st_leave_dead"))
	stateMachine.set_initial_state(Callable(self, "st_idle_update"))
	
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
	
	#superjump
	#if superJumpLengthTimer > 0.0:
	#	superJumpLengthTimer -= delta
	#	print(superJumpLengthTimer)
	#if NodeUtility.is_approximately_equal(superJumpLengthTimer, 0.0, 0.1):
	#	isSuperJumping = false
	
	#respawn
	if respawnTimer > 0.0:
		respawnTimer -= delta
	if NodeUtility.is_approximately_equal(respawnTimer, 0.0, 0.01):
		respawn = true
	
	if justRespawned && (velocity != Vector2.ZERO):
		justRespawned = false
	
	#sprite
	update_sprite(delta)
	
	#stamina
	if is_on_floor() && stateMachine.previousState == Callable(self, "st_climb_update"):
		refill_stamina()
	
	#corner correction
	if velocity.y < 0 && test_move(global_transform, Vector2(0, velocity.y * delta)):
		
		for i in range(1, upwardCornerCorrection * 2 + 1):
			for direction in [-1.0, 1.0]:
				var offset = Vector2(i * direction / 2, 0)
				
				if !test_move(global_transform.translated(Vector2(i * direction / 2, 0)), Vector2(0, velocity.y * delta)):
					translate(offset)
					if velocity.x * direction < 0: velocity.x = 0
					return

func update_sprite(delta: float) -> void:
	# scale tweening
	sprite.scale.x = move_toward(sprite.scale.x, 1.0, bodySquashStretchReversion * delta)
	sprite.scale.y = move_toward(sprite.scale.y, 1.0, bodySquashStretchReversion * delta)
	
	#anims
	if canControl && !sequenceState:
		#idle
		if stateMachine.currentState == Callable(self, "st_idle_update"):
			animationPlayer.play("anim_idle")
		
		#move
		elif stateMachine.currentState == Callable(self, "st_move_update"):
			animationPlayer.play("anim_run")
		
		#jump
		elif stateMachine.currentState == Callable(self, "st_jump_update"):
			animationPlayer.play("anim_jump")
		
		#fall
		elif stateMachine.currentState == Callable(self, "st_fall_update"):
			animationPlayer.play("anim_jump")
		
		#dash
		elif stateMachine.currentState == Callable(self, "st_dash_update"):
			pass
		
		#climb
		elif stateMachine.currentState == Callable(self, "st_climb_update"):
			pass
		
		#duck
		elif stateMachine.currentState == Callable(self, "st_duck_update"):
			animationPlayer.play("anim_duck")

# inputs
func player_input() -> void:
	if Input.is_action_pressed("right"):
		facing.x += 1
		direction = Vector2.RIGHT
		lastDir = Vector2.RIGHT
		sprite.flip_h = false
	if Input.is_action_pressed("left"):
		facing.x -= 1
		direction = Vector2.LEFT
		lastDir = Vector2.LEFT
		sprite.flip_h = true
	if Input.is_action_pressed("down"):
		facing.y += 1
	if Input.is_action_pressed("up"):
		facing.y -= 1
	
	jumpInput = Input.is_action_just_pressed("jump")
	dashInput = Input.is_action_just_pressed("dash")
	climbInput = Input.is_action_pressed("climb")
	duckInput = Input.is_action_pressed("duck")

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
func st_idle_update(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	canJump = true
	
	if !NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move_update")
	
	if (jumpInput || jumpBuffer) && canJump:
		jumpBuffer = false
		return Callable(self, "st_jump_update")
	
	if velocity.y > 0:
		return Callable(self, "st_fall_update")
	
	if canDash:
		return Callable(self, "st_dash_update")
	
	if duckInput:
		return Callable(self, "st_duck_update")
	
	return Callable()

func st_enter_idle(delta: float = 0) -> void:
	#print("IDLE")
	canJump = true
	
	if stateMachine.previousState == Callable(self, "st_fall"):
		sprite.scale = bodySquashVec
	
	refill_dashes()

func st_leave_idle(delta: float = 0) -> void:
	pass

#move
func st_move_update(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_idle_update")
	
	if jumpInput || jumpBuffer:
		jumpBuffer = false
		return Callable(self, "st_jump_update")
	
	if velocity.y > 0:
		return Callable(self, "st_fall_update")
	
	if canDash: 
		return Callable(self, "st_dash_update")
	
	if duckInput:
		return Callable(self, "st_duck_update")
	
	return Callable()

func st_enter_move(delta: float = 0) -> void:
	#print("MOVE")
	if stateMachine.previousState == Callable(self, "st_fall"):
		sprite.scale = bodySquashVec
	refill_dashes()

func st_leave_move(delta: float = 0) -> void:
	pass

#jump
func st_jump_update(delta: float) -> Callable: # every frame
	_gravity_process(delta)
	player_movement(delta)
	
	if jumpInput:
		jumpBuffer = true
		start_jump_buffer_timer()
	
	# variable jump height
	if Input.is_action_just_released("jump"): 
		velocity.y *= variableJumpH 
	
	if velocity.y >= 0:
		return Callable(self, "st_fall_update")
	
	if canDash: 
		return Callable(self, "st_dash_update")
	
	return Callable()

func st_enter_jump(delta: float = 0) -> void: #once
	print("JUMP")
	sprite.scale = bodyStretchVec
	canJump = false
	
	velocity.y = jumpHeight

func st_leave_jump(delta: float = 0) -> void:
	pass

#fall
func st_fall_update(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if is_on_floor() && !NodeUtility.is_approximately_equal(velocity.x, 0):
		return Callable(self, "st_move_update")
	
	if is_on_floor():
		return Callable(self, "st_idle_update")
	
	if (jumpInput || jumpBuffer) && canJump:
		return Callable(self, "st_jump_update")
	
	if canDash: 
		return Callable(self, "st_dash_update")
	
	if get_climbable_dir_next_to_wall() != Vector2.ZERO:
		return Callable(self, "st_climb_update")
	
	return Callable()

func st_enter_fall(delta: float = 0) -> void:
	#print("FALL")
	if stateMachine.previousState == Callable(self, "st_idle_update") || stateMachine.previousState == Callable(self, "st_move_update") || stateMachine.previousState == Callable(self, "st_climb_update"):
		canJump = true
		start_jump_grace_timer()
	else:
		canJump = false
	start_jump_grace_timer()

func st_leave_fall(delta: float = 0) -> void:
	pass

#dash
func st_dash_update(delta: float) -> Callable:
	jumpInput = Input.is_action_just_pressed("jump")
	if jumpInput:
		print(jumpInput)
	
	if dashTrailTimer > 0:
		dashTrailTimer -= delta
		if dashTrailTimer <= 0:
			create_dash_trail()
			dashTrailTimer = dashTrailTime
	
	if dashDir.y == 0:
		pass
	#	if jumpInput && jumpGraceTimer > 0:
	#		return Callable(self, "st_super_jump")
	
	if !isDashing:
		return Callable(self, "st_fall_update")
	
	return Callable()

func st_enter_dash(delta: float = 0) -> void:
	#print("DASH")
	totalDashes = max(0, totalDashes - 1)
	isDashing = true
	dashParticles.emitting = true
	sprite.scale = bodySquashVec
	
	dashLengthTimer = dashLengthTime
	dashCooldownTimer = dashCooldownTime
	dashTrailTimer = dashTrailTime
	start_jump_grace_timer()
	
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
	
	dashDir = Vector2.ZERO

func leave_dash_events() -> void:
	totalDashesSession += 1

#climb
func st_climb_update(delta: float) -> Callable:
	_gravity_process(delta)
	player_movement(delta)
	
	if climbInput && climbStamina > 0:
		if facing.y == -1 && has_enough_stamina(climbStaminaActions.climbUp):
			velocity.y = climbUpSpeed
			
			#get_ledge_grabbable()
			#print("is grabbable: %s" % get_ledge_grabbable())
		elif facing.y == 1:
			velocity.y = climbDownSpeed
		else:
			velocity.y = 0
		climbStamina -= delta
	else:
		climbStamina -= delta
		velocity.y *= climbFriction
	
	print(climbStamina)
	
	if jumpInput && has_enough_stamina(climbStaminaActions.jump):
		
		climbStamina -= climbJumpStaminaDrain
		return Callable(self, "st_jump_update")
	
	if get_climbable_dir_next_to_wall() == Vector2.ZERO:
		return Callable(self, "st_fall_update")
	
	if canDash:
		return Callable(self, "st_dash_update")
	
	if is_on_floor():
		refill_stamina()
		return Callable(self, "st_idle_update")
	
	return Callable()

func st_enter_climb(delta: float = 0) -> void:
	print("CLIMB")
	pass

func st_leave_climb(delta: float = 0) -> void:
	pass

#superjump
#func st_superJump_update(delta: float) -> void:
#	velocity.x = superJumpX * dashDir.x
#	
#	if dashTrailTimer > 0:
#		dashTrailTimer -= delta
#		if dashTrailTimer <= 0:
#			create_dash_trail()
#			dashTrailTimer = dashTrailTime
#	
#	if superJumpLengthTimer <= 0:
#		isSuperJumping = false
#		return Callable(self, "st_fall_update")

#func st_enter_super_jump(delta: float = 0) -> void:
#	#print("SUPERJUMP")
#	isSuperJumping = true
#	dashParticles.emitting = true
#	
#	superJumpLengthTimer = superJumpLengthTime
#	dashTrailTimer = dashTrailTime
#	
#	if facing != Vector2.ZERO:
#		dashDir = facing
#	else:
#		dashDir = lastDir
#	
#	dashParticles.direction = dashDir.normalized()
#	velocity.y = jumpHeight

#func st_leave_super_jump(delta: float = 0) -> void:
#	isSuperJumping = false

#duck
func st_duck_update(delta: float) -> Callable:
	_gravity_process(delta)
	canJump = true
	jumpInput = Input.is_action_just_pressed("jump")
	
	if velocity.x != 0:
		apply_velocity(Vector2(0, velocity.y), duckFriction, delta)
	
	if velocity.y > 0:
		return Callable(self, "st_fall_update")
	
	if !duckInput:
		return Callable(self, "st_idle_update")
	
	if jumpInput && canJump:
		return Callable(self, "st_jump_update")
	
	return Callable()

func st_enter_duck(delta: float = 0) -> void:
	#print("DUCK")
	sprite.scale = bodyDuckSquashVec
	
	duckedCollisionBox.disabled = false
	normalCollisionBox.disabled = true

func st_leave_duck(delta: float = 0) -> void:
	duckedCollisionBox.disabled = true
	normalCollisionBox.disabled = false

#respawn
func st_respawn_update(delta: float) -> void:
	return Callable()

func st_enter_respawn(delta: float = 0) -> void:
	print("RESPAWN")
	pass

func st_leave_respawn(delta: float = 0) -> void:
	pass

#dead
func st_dead_update(delta: float) -> void:
	return Callable()

func st_enter_dead(delta: float = 0) -> void:
	print("DEAD")
	pass

func st_leave_dead(delta: float = 0) -> void:
	pass

# getters
var canDash: bool:
	get:
		return dashInput && dashCooldownTimer <= 0.0 && totalDashes > 0

var canControl: bool:
	get:
		match stateMachine.currentState:
			"st_respawn_update":
				return false
			"st_dead_update":
				return false
			_:
				return true

var sequenceState: bool:
	get:
		match stateMachine.currentState:
			"st_respawn_update":
				return true
			"st_dead_update":
				return true
			_:
				return false

func get_climb_stamina() -> float:
	return climbStamina

func get_climbable_dir_next_to_wall() -> Vector2:
	for raycast: RayCast2D in climbWallRaycasts.get_children():
		raycast.force_raycast_update()
		if raycast.is_colliding():
			if raycast.target_position.x > 0:
				return Vector2.RIGHT
			else:
				return Vector2.LEFT
	return Vector2.ZERO

func get_ledge_grabbable() -> bool:
	var topRaycasts: Array = climbLedgeGrabTopRaycasts
	var midRaycasts: Array = climbLedgeGrabMiddleRaycasts
	var topIsColliding: bool = false
	var midIsColliding: bool = false
	
	for i: RayCast2D in topRaycasts:
		i.force_raycast_update()
		if !i.is_colliding():
			topIsColliding = false
			print("top didnt colliding")
			break
		else:
			print("top collided")
	
	for i: RayCast2D in midRaycasts:
		i.force_raycast_update()
		if i.is_colliding():
			midIsColliding = true
			print("mid collided")
			break
		else:
			print("mid didnt collide")
	
	return topIsColliding && midIsColliding

func create_dash_trail() -> void:
	var ghostInstance: Sprite2D = dashGhost.instantiate()
	ghostInstance.texture = sprite.texture
	ghostInstance.hframes = sprite.hframes
	ghostInstance.global_position = sprite.global_position
	ghostInstance.flip_h = sprite.flip_h
	ghostInstance.modulate = ghostDashColor
	get_parent().get_node("DashGhostContainer").add_child(ghostInstance)

func refill_dashes() -> bool:
	if totalDashes < maxDashes:
		totalDashes = maxDashes
		return true
	return false

func refill_stamina() -> bool:
	if climbStamina < climbMaxStamina:
		climbStamina = climbMaxStamina
		print("refilled stamina")
		return true
	return false

func has_enough_stamina(move: climbStaminaActions):
	var moveList = climbStaminaActions
	match move:
		moveList.jump:
			if climbStamina > climbJumpStaminaDrain:
				return true
			else:
				return false
		moveList.climbUp:
			if climbStamina > climbUpStaminaDrain:
				return true
			else:
				return false

#func get_debug_trail_color() -> Color:
#	match stateMachine.currentState:
#		"st_idle_update":
#			return Color.WHITE
#		"st_move_update":
#			return Color.AQUA
#		"st_jump_update":
#			return Color.DARK_RED
#		"st_fall_update":
#			return Color.DIM_GRAY
#		"st_dash_update":
#			return Color.PURPLE
#		"st_climb_update":
#			return Color.CORNFLOWER_BLUE
#		"st_duck_update":
#			return Color.DARK_ORANGE
#		"st_respawn_update":
#			return Color.CRIMSON
#		"st_dead_update":
#			return Color.BLACK
#		_:
#			return Color.WHITE
