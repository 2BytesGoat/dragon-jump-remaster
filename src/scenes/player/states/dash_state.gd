class_name DashState
extends JumpState


func enter(_msg := {}) -> void:
	super()
	var params = owner.physics_params
	owner.lock_velocity_x()
	owner.velocity.y = 0
	owner.velocity.x = owner.max_speed * owner.facing_direction * params.dash_horizontal_multiplier
	owner.modifiers["dash"] = {"velocity": Vector2(1.0, params.dash_gravity_multiplier)}
	owner.show_afterimage = true


func exit() -> void:
	super()
	owner.unlock_velocity_x()
	owner.show_afterimage = false
	owner.remove_modifier("dash")
