class_name JumpState
extends State

@onready var timer: Timer = $Timer
var was_on_wall: bool = false

@onready var effect = preload("res://src/scenes/effects/jump_smoke_effect.tscn")


func _ready() -> void:
	timer.timeout.connect(_on_jump_timer_timeout)


func enter(msg := {}) -> void:
	was_on_wall = false
	owner.has_jumped = true
	timer.start(owner.jump_time_to_peak)
	owner.velocity.y = owner.jump_velocity
	owner.play_animation(self.name)
	
	var was_walled = msg.get("was_walled", false)
	owner._spawn_effect(effect, was_walled)


func physics_update(delta: float) -> void:
	if owner.is_on_wall():
		was_on_wall = true
	
	# is_on_ceiling() is one frame stale because the state machine runs before
	# move_and_slide(). Use a lookahead so the spiderman modifier kicks in before
	# the player clips into the ceiling, instead of one frame after.
	if owner.is_on_ceiling() or _will_hit_ceiling_this_frame(delta):
		owner.add_modifier("spiderman", {"velocity": Vector2(1, 0)})
	
	if (was_on_wall and not owner.is_on_wall()) or owner.is_on_floor():
		owner.velocity.x *= 0.5
		# If we're no longer on a wall but still airborne, we should be falling,
		# not walking. Going to Move here would let the player "walk" in mid-air.
		if owner.is_on_floor():
			state_machine.transition_to("Move")
		else:
			state_machine.transition_to("Fall")
	
	elif not owner.wants_to_jump:
		_on_jump_timer_timeout()


func _will_hit_ceiling_this_frame(delta: float) -> bool:
	if owner.velocity.y >= 0:
		return false
	var motion = owner.velocity * delta
	var collision = owner.move_and_collide(motion, true, 0.08, false)
	if collision:
		return collision.get_normal().dot(Vector2.DOWN) > 0.7
	return false


func exit() -> void:
	was_on_wall = false
	timer.stop()
	
	owner.wants_to_jump = false
	owner.velocity.y = max(owner.velocity.y, 0)
	owner.remove_modifier("spiderman")


func _on_jump_timer_timeout() -> void:
	if was_on_wall:
		state_machine.transition_to("Walled")
	else: 
		state_machine.transition_to("Fall")
