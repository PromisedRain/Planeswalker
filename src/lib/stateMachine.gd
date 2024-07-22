class_name StateMachine
extends Node

var states = {}
var stateNames = {}
var currentState: Callable
var previousState: Callable

func update(delta: float) -> void:
	if currentState:
		var nextState = currentState.call(delta)
		if nextState and nextState != currentState:
			change_state(nextState)

func add_states(stName: String, normal: Callable, enterState: Callable, leaveState: Callable):
	var stateFlow = StateFlows.new(normal, enterState, leaveState)
	states[normal] = stateFlow
	stateNames[normal] = stName

func change_state(state: Callable) -> void:
	if states.has(state):
		call_deferred("set_state", states[state])

func set_state(state: StateFlows) -> void:
	if currentState:
		if states.has(currentState):
			var currentStateFlow = states[currentState] # selects the specific state flow from the dictionary that contains them.
			if currentStateFlow.leaveState: # then it checks if it has a leave state,
				currentStateFlow.leaveState.call() # and if it does then it invokes the method.
			previousState = currentState # then just sets the state as the previous state (for stuff).
	currentState = state.normal # then it sets the current state as the state thats being inputteds normal (normal is just what happens while the state is active).
	if state.enterState:
		state.enterState.call()

func set_initial_state(state: Callable):
	if states.has(state):
		set_state(states[state])

func get_current_state():
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
	
	func _init(normal: Callable, enterState: Callable, leaveState: Callable):
		self.normal = normal
		self.enterState = enterState
		self.leaveState = leaveState
