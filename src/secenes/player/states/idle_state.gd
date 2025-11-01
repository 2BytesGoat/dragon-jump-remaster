class_name IdleState
extends State


func enter(_msg := {}) -> void:
	owner.add_modifier("idle", {"velocity": Vector2(0, 0)})
	owner.play_animation(self.name)


func update(_delta: float) -> void:
	if not owner.started_walking:
		return
	
	if not owner.is_on_floor():
		state_machine.transition_to("Fall")
	else:
		state_machine.transition_to("Move")


func exit() -> void:
	owner.remove_modifier("idle")
