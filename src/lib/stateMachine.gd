class_name StateMachine
extends Node

var states: Dictionary = {} 
var stateNames: Dictionary = {}
var currentState: Callable
var previousState: Callable

func update(delta: float) -> void: 
	if currentState: 
		var nextState = currentState.call(delta) 
		if nextState and nextState != currentState:
			change_state(nextState, delta)

func add_states(stName: String, normal: Callable, enterState: Callable, leaveState: Callable) -> void:
	var stateFlow = StateFlows.new(normal, enterState, leaveState) 
	states[normal] = stateFlow
	stateNames[normal] = stName 

func change_state(state: Callable, delta: float) -> void:
	if states.has(state):
		call_deferred("set_state", states[state], delta) 

func set_state(state: StateFlows, delta: float = 0) -> void:
	if currentState:
		if states.has(currentState):
			var currentStateFlow = states[currentState] 
			if currentStateFlow.leaveState:
				currentStateFlow.leaveState.call(delta) 
			previousState = currentState 
	currentState = state.normal 
	if state.enterState: 
		state.enterState.call(delta)

func set_initial_state(state: Callable):
	if states.has(state):
		set_state(states[state])

func get_current_state() -> Callable:
	return currentState

func get_current_state_name() -> String:
	if stateNames.has(currentState):
		return stateNames[currentState]
	else:
		return "unknown state"


class StateFlows:
	var normal: Callable 
	var enterState: Callable
	var leaveState: Callable
	
	@warning_ignore("shadowed_variable")
	func _init(normal: Callable, enterState: Callable, leaveState: Callable):
		self.normal = normal
		self.enterState = enterState
		self.leaveState = leaveState
