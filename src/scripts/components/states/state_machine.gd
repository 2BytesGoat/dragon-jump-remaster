# Generic state machine. Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the active state.
class_name StateMachine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(state_name)

# Path to the initial active state. We export it to be able to pick the initial state in the inspector.
@export var initial_state := NodePath()

# The current active state. At the start of the game, we get the `initial_state`.
var state: State

var initialized = false
# Cached state nodes by name to avoid repeated get_node() lookups on transition.
var _state_cache: Dictionary = {}

# When true, the owning node is responsible for calling physics_update() manually.
# This prevents the state machine from running its own _physics_process callback
# and allows the owner to integrate velocity exactly once per frame.
@export var manual_physics_process: bool = false


func _ready() -> void:
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.state_machine = self
		_state_cache[child.name] = child
	
	var initial_name := _node_path_name(initial_state)
	state = _state_cache.get(initial_name)
	reset()


# The state machine subscribes to node callbacks and delegates them to the state objects.
func _unhandled_input(event: InputEvent) -> void:
	if not is_inside_tree() or is_queued_for_deletion() or not state:
		return
	state.handle_input(event)


func _process(delta: float) -> void:
	if not is_inside_tree() or is_queued_for_deletion() or not state:
		return
	state.update(delta)


func _physics_process(delta: float) -> void:
	if manual_physics_process or not is_inside_tree() or is_queued_for_deletion() or not state:
		return
	state.physics_update(delta)


# Public entry point for owners that drive the state machine manually.
# Calls the active state's physics_update without running the internal
# _physics_process callback again.
func step_physics(delta: float) -> void:
	if not is_inside_tree() or is_queued_for_deletion() or not state:
		return
	state.physics_update(delta)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter() function.
func _node_path_name(path: NodePath) -> String:
	if path.get_name_count() == 0:
		return ""
	return path.get_name(path.get_name_count() - 1)


# This function calls the current state's exit() function, then changes the active state,
# and calls its enter function.
# It optionally takes a `msg` dictionary to pass to the next state's enter function.
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	# Safety check, you could use an assert() here to report an error if the state name is incorrect.
	# We don't use an assert here to help with code reuse. If you reuse a state in different state machines
	# but you don't want them all, they won't be able to transition to states that aren't in the scene tree.
	var next_state: State = _state_cache.get(target_state_name)
	if next_state == null:
		return

	state.exit()
	state = next_state
	state.enter(msg)
	emit_signal("transitioned", state.name)

func reset() -> void:
	if not initialized:
		await owner.ready
		if not is_inside_tree() or is_queued_for_deletion():
			return
		initialized = true
		# Cache may not have been built if children were added after _ready.
		if _state_cache.is_empty():
			for child in get_children():
				if child is State:
					_state_cache[child.name] = child
	
	var initial_name := _node_path_name(initial_state)
	state = _state_cache.get(initial_name)
	if state == null:
		state = get_node(initial_state)
		_state_cache[initial_name] = state
	state.enter()
