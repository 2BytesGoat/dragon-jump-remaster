extends CharacterBody2D

# movement properties
@export var max_speed: float = 220.0
@export var default_friction: float = 1000.0     # Default friction when on normal surfaces
var current_friction: float = default_friction   # Current friction based on surface
var facing_direction: int = Vector2i.RIGHT.x
var started_walking: bool = false

# jump properties
@export var jump_height: float = 100.0           # Height in pixels
@export var jump_time_to_peak: float = 0.3       # Time in seconds to reach peak
@export var jump_time_to_descent: float = 0.3    # Time in seconds to descent
var wants_to_jump: bool = false

# Physics properties
var jump_velocity: float = ((-2.0 * jump_height) / jump_time_to_peak)         # Calculated jump velocity
var jump_gravity: float  = (2.0 * jump_height) / (jump_time_to_peak ** 2)     # Calculated gravity for jump
var fall_gravity: float  = (2.0 * jump_height) / (jump_time_to_descent ** 2)  # Calculated gravity for fall

# State
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/Idle
var modifiers: Dictionary = {}


func _ready() -> void:
	state_machine.initial_state = initial_state.get_path()


func add_modifier(modifier_name: String, modifier_value: Dictionary) -> void:
	# TODO: make a modifier type object
	modifiers[modifier_name] = modifier_value


func remove_modifier(modifier_name: String) -> void:
	modifiers.erase(modifier_name)


func play_animation(_animation_name: String) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		started_walking = true


func _physics_process(delta: float) -> void:
	if not started_walking:
		return

	_update_friction()
	
	velocity.x = move_toward(velocity.x, max_speed * facing_direction, current_friction * delta)
	velocity.y += _get_actual_gravity() * delta
	
	_apply_modifiers()
	
	move_and_slide()


func _get_actual_gravity() -> float:
	return jump_gravity if velocity.y < 0 else fall_gravity


func _update_friction() -> void:
	if is_on_floor():
		# Check for surface type and update friction accordingly
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == null:
				return
			if collision.get_collider().has_method("get_friction"):
				current_friction = collision.get_collider().get_friction()
				return
		# If no special surface, use default friction
		current_friction = default_friction
	else:
		# In air, use default friction
		current_friction = default_friction


func _apply_modifiers() -> void:
	for modifier in modifiers.values():
		velocity *= modifier.get("velocity", 1.0) 
