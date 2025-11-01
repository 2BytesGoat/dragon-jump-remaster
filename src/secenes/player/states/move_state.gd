class_name PlayerStateMove
extends State


func enter(_msg := {}) -> void:
	owner.play_animation(self.name)


func physics_update(_delta: float) -> void:
	if owner.is_on_wall():
		owner.facing_direction *= -1
	
	if owner.wants_to_jump:
		state_machine.transition_to("Jump")
