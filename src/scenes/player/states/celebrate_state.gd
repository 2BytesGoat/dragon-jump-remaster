class_name CelebrateState
extends State


func enter(_msg := {}) -> void:
	owner.is_paused = true
	owner.velocity = Vector2.ZERO
	owner.play_animation("Celebrate")


func physics_update(_delta: float) -> void:
	pass
