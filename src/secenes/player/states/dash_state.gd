class_name DashState
extends JumpState


func enter(_msg := {}) -> void:
	super()
	owner.velocity.y = 0
	owner.velocity.x = owner.max_speed * 1.75
	owner.show_afterimage = true


func physics_update(delta: float) -> void:
	super(delta)
	owner.velocity.y = 0


func exit() -> void:
	super()
	owner.show_afterimage = false
