class_name StateMachine
extends Node

#inspired by a c++ statemachine system i had seen before.
#
#example of use as a statemachine for a player.
#
#var stateMachine: StateMachine = StateMachine.new()
#
#func _ready() -> void:
#	var states = ["idle", "move", "jump", "fall", "dash", "slide", "duck"]
#	
#	for state in states:
#		stateMachine.add_states(
#			state,
#			Callable(self, "st_%s" % state),
#			Callable(self, "st_enter_%s" % state),
#			Callable(self, "st_leave_%s" % state)
#		)
#	stateMachine.set_initial_state(Callable(self, "st_idle"))
#
#func st_idle():
#	pass
#
#func st_enter_idle():
#	pass
#
#func st_leave_idle():
#	pass
#
#etc...

var states = {} # dictionary of states.
var stateNames = {}
var currentState: Callable
var previousState: Callable

func update(delta: float) -> void: # update loop.
	if currentState: 
		var nextState = currentState.call(delta) 
		if nextState and nextState != currentState: # checks if the next state is not the current state, if so then it changes state.
			change_state(nextState, delta)

func add_states(stName: String, normal: Callable, enterState: Callable, leaveState: Callable):
	var stateFlow = StateFlows.new(normal, enterState, leaveState) #registering a state. normal(every frame), enter(1 time when you enter), leave(1 time when you leave)
	states[normal] = stateFlow # adds the registered stateflow inside the dictionary of states.
	stateNames[normal] = stName 

func change_state(state: Callable, delta: float) -> void:
	if states.has(state): # checks if the dictionary states has a specific stored state. if it does, then it calls set_state, on that specific state.
		call_deferred("set_state", states[state], delta) 

func set_state(state: StateFlows, delta: float = 0) -> void:
	if currentState:
		if states.has(currentState):
			var currentStateFlow = states[currentState] # selects the specific state flow from the dictionary that contains them.
			if currentStateFlow.leaveState: # then it checks if it has a leave state,
				currentStateFlow.leaveState.call(delta) # and if it does then it invokes the method.
			previousState = currentState # then just sets the state as the previous state (for stuff).
	currentState = state.normal # then it sets the current state as the state thats being inputteds normal (normal is just what happens while the state is active).
	if state.enterState: # checks for a enterstate in the stateflow, if it has one, it invokes it.
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

# stateflows is just a template for how a state ususally is
class StateFlows:
	var normal: Callable # a normal which is updated every process, this usually has the methods for switching to a different state.
	var enterState: Callable # a method that gets called once when you either change state or just initialize as a specific state.
	var leaveState: Callable # a method that gets called once when you either change state or just leave a specific state.
	
	func _init(normal: Callable, enterState: Callable, leaveState: Callable): # constructor.
		self.normal = normal
		self.enterState = enterState
		self.leaveState = leaveState
