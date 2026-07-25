class_name BounceState extends State


@onready var timer: Timer = $Timer
var was_on_wall: bool = false

@onready var effect = preload("res://src/scenes/effects/jump_smoke_effect.tscn")


func _ready() -> void:
	timer.timeout.connect(_on_jump_timer_timeout)


func enter(msg := {}) -> void:
	was_on_wall = false
	var params = owner.physics_params
	var push_direction: Vector2 = msg.get("push_direction", Vector2.ZERO)
	owner.lock_velocity_x()
	# --- Horizontal push ---
	if push_direction.x != 0:
		owner.facing_direction = sign(push_direction.x)
		owner.velocity.x = owner.max_speed * push_direction.x * params.bounce_horizontal_multiplier

	# --- Vertical push (ONLY if requested) ---
	if push_direction.y < 0:
		# Upward push (jump)
		owner.velocity.y = owner.jump_velocity * abs(push_direction.y) * params.bounce_upward_multiplier
	elif push_direction.y > 0:
		# Downward push (slam / knockdown)
		owner.velocity.y = owner.jump_velocity * -push_direction.y * params.bounce_downward_multiplier

	timer.start(owner.jump_time_to_peak)
	owner.play_animation("Move")


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		was_on_wall = true
	
	if owner.is_on_ceiling():
		owner.add_modifier("spiderman", {"velocity": Vector2(1, 0)})
	
	if (was_on_wall and not owner.is_on_wall()) or owner.is_on_floor():
		owner.velocity.x *= 0.5
		state_machine.transition_to("Move")


func exit() -> void:
	owner.unlock_velocity_x()
	was_on_wall = false
	timer.stop()
	owner.remove_modifier("spiderman")


func _on_jump_timer_timeout() -> void:
	if was_on_wall:
		state_machine.transition_to("Walled")
	else: 
		state_machine.transition_to("Fall")
