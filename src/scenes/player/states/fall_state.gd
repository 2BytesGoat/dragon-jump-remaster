class_name FallState
extends State


func enter(msg := {}) -> void:
	if msg.has("was_walled"):
		owner.add_modifier("walled_fall", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)


func physics_update(delta: float) -> void:
	# Prefer handling a normal landing over spending a powerup. is_on_floor()
	# is stale here because the state machine runs before Player._physics_process,
	# so landing is checked again when gating the powerup cast.
	if owner.is_on_floor():
		if not owner.started_walking:
			state_machine.transition_to("Idle")
		else:
			owner.velocity = owner.velocity * 0.5
			state_machine.transition_to("Move")
		return
	
	if owner.wants_to_jump and owner.has_powerups():
		# Don't burn a powerup if the jump button was pressed just before the
		# player lands; let it become a normal ground jump instead.
		if not _will_land_this_frame(delta):
			var powerup_name = owner.consume_powerup()
			state_machine.transition_to(powerup_name)
			return
	
	if owner.is_on_wall():
		state_machine.transition_to("Walled")


func _will_land_this_frame(delta: float) -> bool:
	if owner.velocity.y <= 0:
		return false
	
	var motion = owner.velocity * delta
	var collision = owner.move_and_collide(motion, true, 0.08, false)
	if collision:
		return collision.get_normal().dot(Vector2.UP) > 0.7
	return false


func exit() -> void:
	owner.modifiers.erase("walled_fall")
