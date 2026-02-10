class_name Player
extends CharacterBody2D

enum CONTROLLERS {
	NONE,
	PLAYER_ONE,
	PLAYER_TWO,
	TRAINING
}
@export var controller_type: CONTROLLERS = CONTROLLERS.NONE : set = _on_player_controller_changed

# movement properties
@export var starting_facing_direction: int = Vector2i.RIGHT.x
var default_max_speed: float = 220.0
var default_acceleration: float = 250.0
var default_friction: float = 100.0     # Default friction when on normal surfaces
var max_speed: float = 220.0
var acceleration: float = 250.0

# jump properties
var jump_height: float = 72.0                     # Height in pixels
var default_jump_time_to_peak: float = 0.37       # Time in seconds to reach peak
var default_jump_time_to_descent: float = 0.23    # Time in seconds to descent
var jump_time_to_peak: float = 0.37
var jump_time_to_descent: float = 0.23

# Physics properties
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# State
@onready var state_machine: StateMachine = $StateMachine
@onready var initial_state: State = $StateMachine/Idle

# Controllers
@onready var controller_container: Node = $ControllerContainer
var active_controller: PlayerCharacterController = null

# Nodes
@onready var flippable_container: Node2D = $Flippable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var afterimage: CPUParticles2D = $Flippable/AfterImage
@onready var grappling_hook: Node2D = $Flippable/GaplingHook
@onready var hat_container: Node2D = $Flippable/HatContainer
var has_crown: bool = false
var last_floor_position: Vector2 = Vector2.ZERO
var is_done: bool = false

# Signals
signal picked_powerup(powerup_name: String, id: int)
signal used_powerup(id: int)
signal has_resetted

# Effects
@onready var spawn_smoke = preload("res://src/scenes/effects/spawn_smoke_effect.tscn")
@onready var despawn_smoke = preload("res://src/scenes/effects/despawn_smoke_effect.tscn")
@onready var powerup_sfx: AudioStreamPlayer = $PowerupSFX

# Reset params
var current_friction: float = default_friction   # Current friction based on surface
var facing_direction: int = Vector2i.RIGHT.x
var started_walking: bool = false
var is_paused: bool = false
var wants_to_jump: bool = false
var needs_to_release: bool = false
var modifiers: Dictionary = {}
var powerups: Array = []
var starting_position: Vector2 = Vector2.ZERO
var show_afterimage: bool = false : set = _on_show_after_image_changed
var speed_modifier: float = 1.0 : set = _on_speed_modifier_changed


func _ready() -> void:
	starting_position = global_position
	_on_player_controller_changed(controller_type)
	_on_speed_modifier_changed(speed_modifier)
	reset()


func _physics_process(delta: float) -> void:
	if not started_walking or is_done or is_paused:
		return
	
	velocity.x = move_toward(velocity.x, max_speed * facing_direction, acceleration * delta)
	velocity.y += _get_actual_gravity() * delta
	
	_apply_modifiers()
	#_update_friction()
	_update_facing_direction()
	
	move_and_slide()


func set_controller(controller: PlayerCharacterController) -> void:
	if controller_container == null:
		await ready
	
	for child in controller_container.get_children():
		child.queue_free()
	
	active_controller = controller
	controller_container.add_child(controller)


func set_jump(input: bool) -> void:
	if input:
		if not started_walking:
			started_walking = true
			SignalBus.player_started_run.emit(self)
			return
		wants_to_jump = true
	else:
		wants_to_jump = false
		needs_to_release = false


func reset() -> void:
	if is_done:
		return
	
	drop_crown()
	SignalBus.player_restarted_run.emit(self)
	Utils.instance_scene_on_main(despawn_smoke, self.global_position)
	current_friction = default_friction 
	facing_direction = starting_facing_direction
	started_walking = false
	wants_to_jump = false
	needs_to_release = false
	show_afterimage = false
	modifiers = {}
	
	for i in range(len(powerups)):
		consume_powerup()
	
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
	var interacted_areas = powerups.map(func(x): return x[0])
	if area.name in interacted_areas:
		return
	var powerup_type = area.get_powerup()
	powerups.append([area.name, powerup_type])
	picked_powerup.emit(powerup_type, len(powerups) - 1)


func has_powerups() -> bool:
	return len(powerups) > 0


func consume_powerup() -> String:
	# TODO: find a better way to do this
	var powerup_name = powerups.pop_back()[1]
	used_powerup.emit(len(powerups))
	return powerup_name


func launch_grappling_hook() -> void:
	grappling_hook.launch()


func release_grappling_hook() -> void:
	grappling_hook.release()


func drop_crown() -> void:
	for child in hat_container.get_children():
		if not child.is_in_group("Crown"):
			continue
		
		child.reparent(get_parent())
		child.global_position = last_floor_position
		child.drop()
		has_crown = false
		SignalBus.player_dropped_crown.emit(self)


func _on_speed_modifier_changed(value) -> void:
	speed_modifier = value
	
	jump_time_to_peak = default_jump_time_to_peak * (1 / speed_modifier)
	jump_time_to_descent = default_jump_time_to_descent * (1 / speed_modifier)
	
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
	match controller_type:
		CONTROLLERS.PLAYER_ONE:
			set_controller(PlayerOneController.new(self))
		CONTROLLERS.PLAYER_TWO:
			set_controller(PlayerTwoController.new(self))
		CONTROLLERS.TRAINING:
			set_controller(PlayerAITrainingController.new(self))


func _on_hurt_box_body_entered(body: Node2D) -> void:
	# This is for spikes
	if body is TileMapLayer:
		reset()


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
		SignalBus.player_finished_run.emit(self)


func _on_interact_box_area_exited(area: Area2D) -> void:
	if area.is_in_group("Slippery"):
		remove_modifier("slippery")


func _on_interact_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("StaticLayer"):
		starting_position = global_position
		starting_facing_direction = facing_direction
