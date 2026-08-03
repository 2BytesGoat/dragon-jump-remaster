class_name DieState
extends State


func enter(_msg := {}) -> void:
	owner.is_dead = true
	owner.is_paused = true
	owner.velocity = Vector2.ZERO
	owner.flippable_container.visible = false
	Utils.instance_scene_on_main(owner.despawn_smoke, owner.global_position)
	owner.play_animation("Die")


func physics_update(_delta: float) -> void:
	pass
