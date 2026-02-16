class_name Ghost
extends AnimatedSprite2D


func update(new_position, facing_direction, state):
	self.global_position = new_position
	self.scale.x = facing_direction
	self.play(state)
