class_name PlayerStateFall
extends State


func enter(msg := {}) -> void:
	if msg.has("was_walled"):
		owner.add_modifier("fall", {"velocity": Vector2(0, 1)})
	owner.play_animation(self.name)

func physics_update(_delta: float) -> void:
	if owner.wants_to_jump and owner.has_powerup("DoubleJump"):
		owner.consume_powerup("DoubleJump")
		state_machine.transition_to("Jump")
	
	if owner.is_on_wall():
		#state_machine.transition_to("Walled")
		pass
	
	if owner.is_on_floor():
		state_machine.transition_to("Idle")

func exit() -> void:
	owner.modifiers.erase("fall")
