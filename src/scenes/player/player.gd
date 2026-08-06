class_name Player
extends CharacterBody2D

enum CONTROLLERS {
	NONE,
	PLAYER_ONE,
	TRAINING
}
@export var controller_type: CONTROLLERS = CONTROLLERS.NONE : set = _on_player_controller_changed

# movement properties
@export var starting_facing_direction: int = Vector2i.RIGHT.x
@export var physics_params: PhysicsParams = Constants.PHYSICS_PARAMS

var default_max_speed: float
var default_acceleration: float
var default_friction: float     # Default friction when on normal surfaces
var max_speed: float
var acceleration: float

# jump properties
var jump_height: float                     # Height in pixels
var default_jump_time_to_peak: float       # Time in seconds to reach peak
var default_jump_time_to_descent: float    # Time in seconds to descent
var jump_time_to_peak: float
var jump_time_to_descent: float

# Physics properties
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# State
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/Idle
@onready var jump_timer: Timer = $StateMachine/Jump/Timer

# When true, the state controls horizontal velocity directly and the global
# move_toward acceleration is skipped for this frame. States that apply an
# immediate horizontal impulse (bounce, dash) set this during enter/exit.
var velocity_x_locked: bool = false

# Controllers
@onready var controller_container: Node = $ControllerContainer
var active_controller: PlayerCharacterController = null
var _current_controller_type: int = -1

# Nodes
@onready var flippable_container: Node2D = $Flippable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var afterimage: CPUParticles2D = $Flippable/AfterImage
@onready var grappling_hook: Node2D = $Flippable/GrapplingHook
@onready var hat_container: Node2D = $Flippable/HatContainer
var last_floor_position: Vector2 = Vector2.ZERO
var is_done: bool = false

# Signals
signal picked_powerup(powerup_name: String, id: int, pickup_global_position: Vector2)
signal used_powerup(id: int)
signal powerup_consumed(type: String)
signal has_resetted
signal run_started(player: Player)
signal run_restarted(player: Player)
signal run_finished(player: Player)
signal died(player: Player)

# Juice nodes - assigned by main.gd in initialize_players()
var screen_shake: ScreenShake
var hit_stop: HitStop
var transition_wipe: TransitionWipe
var camera: Camera2D
@export var wipe_duration: float = 0.35

# Effects
@onready var spawn_smoke = preload("res://src/scenes/effects/spawn_smoke_effect.tscn")
@onready var despawn_smoke = preload("res://src/scenes/effects/despawn_smoke_effect.tscn")
@onready var powerup_sfx: AudioStreamPlayer = $PowerupSFX

# Reset params
var current_friction: float = default_friction   # Current friction based on surface
var facing_direction: int = Vector2i.RIGHT.x
var started_walking: bool = false
var is_paused: bool = false
var is_dead: bool = false
var wants_to_jump: bool = false
var needs_to_release: bool = false
var has_jumped: bool = false
var modifiers: Dictionary = {}
var powerups: Array = []
var starting_position: Vector2 = Vector2.ZERO : set = _on_starting_position_changed
var show_afterimage: bool = false : set = _on_show_after_image_changed
var speed_modifier: float = 1.0 : set = _on_speed_modifier_changed

# Only used for the AI controller - find a better way in future
var level_reference: Level
var last_agent_input: bool = false


func _ready() -> void:
	_apply_physics_params()
	starting_position = global_position
	_on_player_controller_changed(controller_type)
	_on_speed_modifier_changed(speed_modifier)
	reset()


func _apply_physics_params() -> void:
	if physics_params == null:
		physics_params = Constants.PHYSICS_PARAMS
	default_max_speed = physics_params.max_speed
	default_acceleration = physics_params.acceleration
	default_friction = physics_params.friction
	jump_height = physics_params.jump_height
	default_jump_time_to_peak = physics_params.jump_time_to_peak
	default_jump_time_to_descent = physics_params.jump_time_to_descent
	max_speed = default_max_speed
	acceleration = default_acceleration


func _physics_process(delta: float) -> void:
	if not started_walking or is_done or is_paused:
		return
	
	# Let the current state compute target velocity / apply impulses first.
	state_machine.step_physics(delta)
	
	# Apply horizontal acceleration unless the active state has taken over.
	if not velocity_x_locked:
		velocity.x = move_toward(velocity.x, max_speed * facing_direction, acceleration * delta)
	
	# Integrate gravity exactly once per frame.
	velocity.y += _get_actual_gravity() * delta
	
	_apply_modifiers()
	#_update_friction()
	_update_facing_direction()
	
	move_and_slide()
	
	if is_on_floor():
		has_jumped = false


func set_controller(controller: PlayerCharacterController) -> void:
	if controller_container == null:
		await ready
	
	for child in controller_container.get_children():
		child.queue_free()
	
	active_controller = controller
	controller_container.add_child(controller)


func set_jump(input: bool) -> void:
	if input == last_agent_input:
		return
	last_agent_input = input
	
	if input:
		if not started_walking:
			started_walking = true
			run_started.emit(self)
			return
		wants_to_jump = true
	else:
		wants_to_jump = false
		needs_to_release = false


func die() -> void:
	if is_dead:
		return
	is_dead = true
	TelemetrySystem.death("hazard", level_reference.level_name if level_reference != null else "", len(powerups))
	state_machine.transition_to("Die")
	_run_death_sequence()


func _run_death_sequence() -> void:
	if screen_shake != null:
		screen_shake.shake(ScreenShake.Event.DEATH)
	if hit_stop != null:
		await hit_stop.trigger()
	# The player node may be freed (e.g. scene change) during any await below.
	if not is_instance_valid(self):
		return
	if transition_wipe != null:
		transition_wipe.cover(wipe_duration)
		await transition_wipe.cover_midpoint
		if not is_instance_valid(self):
			return
		for i in range(len(powerups)):
			drop_powerup()
		await transition_wipe.covered
		if not is_instance_valid(self):
			return
	if camera != null:
		camera.pan_to(starting_position, 0.0)
	reset()
	if transition_wipe != null:
		transition_wipe.reveal(wipe_duration)
		await transition_wipe.reveal_midpoint
		if not is_instance_valid(self):
			return
	died.emit(self)


func reset() -> void:
	if is_done:
		return

	is_dead = false
	is_paused = false
	flippable_container.visible = true
	run_restarted.emit(self)
	current_friction = default_friction
	facing_direction = starting_facing_direction
	if controller_type != CONTROLLERS.TRAINING:
		started_walking = false
	wants_to_jump = false
	needs_to_release = false
	has_jumped = false
	show_afterimage = false
	modifiers = {}
	last_agent_input = false

	for i in range(len(powerups)):
		drop_powerup()

	velocity = Vector2.ZERO
	global_position = starting_position
	state_machine.transition_to(initial_state.name)
	has_resetted.emit()

	_update_facing_direction()
	animation_player.play("Spawn")
	Utils.instance_scene_on_main(spawn_smoke, self.global_position)


func add_modifier(modifier_name: String, modifier_value: Dictionary) -> void:
	# TODO: make a modifier type object
	modifiers[modifier_name] = modifier_value


func remove_modifier(modifier_name: String) -> void:
	modifiers.erase(modifier_name)


func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)


func set_speedup_progress(progress: float) -> void:
	progress = clamp(progress, 0.0, 1.0)
	velocity.x = lerp(0.0, max_speed * facing_direction, progress)


func pick_powerup(area: Area2D) -> void:
	if area.name in powerups:
		return
	area.pickup()
	powerups.append(area)
	var powerup_type = area.type
	picked_powerup.emit(powerup_type, len(powerups) - 1, area.global_position)


func has_powerups() -> bool:
	return len(powerups) > 0


func consume_powerup() -> String:
	# TODO: find a better way to do this
	var powerup = _pop_powerup()
	if powerup == null:
		return ""
	TelemetrySystem.powerup_used(powerup.type)
	powerup_consumed.emit(powerup.type)
	return powerup.type


func drop_powerup() -> void:
	_pop_powerup()


func _pop_powerup():
	if powerups.is_empty():
		return null
	var powerup = powerups.pop_back()
	powerup.consume()
	used_powerup.emit(len(powerups))
	return powerup


func launch_grappling_hook() -> void:
	grappling_hook.launch()


func release_grappling_hook() -> void:
	grappling_hook.release()


func percentage_towards_jump_peak() -> float:
	return jump_timer.time_left / jump_time_to_peak


func on_wall() -> bool:
	return is_on_wall()


func on_floor() -> bool:
	return is_on_floor()


func lock_velocity_x() -> void:
	velocity_x_locked = true


func unlock_velocity_x() -> void:
	velocity_x_locked = false


func _on_speed_modifier_changed(value) -> void:
	speed_modifier = value
	
	# Guard against division by zero. A zero modifier would freeze jump timing;
	# treat it as 1.0 (no modifier) for the duration/velocity math.
	var safe_modifier := speed_modifier if speed_modifier > 0.0 else 1.0
	jump_time_to_peak = default_jump_time_to_peak * (1.0 / safe_modifier)
	jump_time_to_descent = default_jump_time_to_descent * (1.0 / safe_modifier)
	
	jump_velocity = ((-2.0 * jump_height) / jump_time_to_peak)         # Calculated jump velocity
	jump_gravity  = (2.0 * jump_height) / (jump_time_to_peak ** 2)     # Calculated gravity for jump
	fall_gravity  = (2.0 * jump_height) / (jump_time_to_descent ** 2)  # Calculated gravity for fall
	
	max_speed = default_max_speed * value
	acceleration = default_acceleration * value


func _spawn_effect(effect, was_walled=false):
	var effect_scale = Vector2i(facing_direction, 1)
	var effect_rotation = 0
	if was_walled:
		effect_rotation = PI/2 * facing_direction
		effect_scale.x *= -1
	
	Utils.instance_scene_on_main(effect, global_position, effect_rotation, effect_scale)


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


func _update_facing_direction() -> void:
	flippable_container.scale.x = facing_direction


func _apply_modifiers() -> void:
	for modifier in modifiers.values():
		velocity *= modifier.get("velocity", 1.0) 


func _on_show_after_image_changed(value: bool) -> void:
	show_afterimage = value
	afterimage.emitting = value
	powerup_sfx.playing = value


func _on_player_controller_changed(new_controller_type: CONTROLLERS) -> void:
	controller_type = new_controller_type
	# Guard against double-calls (e.g. setter re-entry or repeated export set):
	# if the type is unchanged, the existing controller is already correct and
	# creating another would leak/orphan the previous one.
	if _current_controller_type == new_controller_type:
		return
	_current_controller_type = new_controller_type
	match controller_type:
		CONTROLLERS.PLAYER_ONE:
			set_controller(PlayerOneController.new(self))
		CONTROLLERS.TRAINING:
			set_controller(PlayerAITrainingController.new(self))


func _on_starting_position_changed(new_position: Vector2) -> void:
	starting_position = new_position
	global_position = starting_position


func _on_hurt_box_body_entered(body: Node2D) -> void:
	# This is for spikes. Spikes live on the StaticLayer (collision layer 4, which
	# the HurtBox masks). Restrict to that group so any other TileMapLayer that
	# might overlap the hurtbox doesn't trigger a death.
	if body.is_in_group("StaticLayer") and not is_dead:
		die()


func _on_interact_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Powerup") and len(powerups) < 3:
		pick_powerup(area)
	elif area.is_in_group("Slippery"):
		# TODO: find a better way to do this
		add_modifier("slippery", {"velocity": Vector2(1.07, 1)})
	elif area.is_in_group("BouncePad"):
		state_machine.transition_to("Bounce", {"push_direction": area.facing_direction})
	elif area.is_in_group("Exit"):
		is_done = true
		show_afterimage = false
		state_machine.transition_to("Celebrate")
		run_finished.emit(self)


func _on_interact_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Slippery"):
		remove_modifier("slippery")


func _on_interact_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("StaticLayer"):
		# Only update the checkpoint when grounded. Without this, brushing a
		# static tile (e.g. a wall) mid-jump moves the respawn point into the air.
		if is_on_floor():
			starting_position = global_position
			starting_facing_direction = facing_direction
