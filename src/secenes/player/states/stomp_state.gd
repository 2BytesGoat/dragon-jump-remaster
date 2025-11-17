class_name StompState
extends State

var is_active = false


func enter(_msg := {}) -> void:
	is_active = true
	owner.show_afterimage = true
	owner.velocity.y = -owner.jump_velocity
	owner.add_modifier("stomp", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)
	owner.set_collision_mask_value(6, false)


func physics_update(_delta: float) -> void:
	if owner.is_on_floor():
		state_machine.transition_to("Idle")


func exit() -> void:
	is_active = false
	owner.velocity.x = owner.max_speed * 0.35 * owner.facing_direction
	owner.modifiers.erase("stomp")
	owner.show_afterimage = false
	owner.set_collision_mask_value(6, true)


func _on_interact_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Destroyable") and is_active:
		area.owner.destroy()
