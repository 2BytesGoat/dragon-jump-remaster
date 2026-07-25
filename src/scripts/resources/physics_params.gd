class_name PhysicsParams
extends Resource

@export var max_speed: float = 220.0
@export var acceleration: float = 250.0
@export var friction: float = 100.0
@export var jump_height: float = 72.0
@export var jump_time_to_peak: float = 0.37
@export var jump_time_to_descent: float = 0.23

# Bounce pad velocity multipliers
@export var bounce_horizontal_multiplier: float = 2.0
@export var bounce_upward_multiplier: float = 1.2
@export var bounce_downward_multiplier: float = 0.5

# Dash velocity multipliers
@export var dash_horizontal_multiplier: float = 1.65
@export var dash_gravity_multiplier: float = -0.01
