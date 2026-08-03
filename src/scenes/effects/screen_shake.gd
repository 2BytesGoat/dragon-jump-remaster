class_name ScreenShake
extends Node

enum Event { DEATH, POWERUP }

@export var enabled: bool = true
@export var camera: Camera2D
@export var death_strength: float = 2.0
@export var powerup_strength: float = 0.5

@export var death_duration: float = 0.15
@export var powerup_duration: float = 0.15


func shake(event: Event) -> void:
	if not enabled or camera == null:
		return
	var dur := _duration_for(event)
	camera.apply_shake(_strength_for(event), dur)


func _strength_for(event: Event) -> float:
	match event:
		Event.DEATH: return death_strength
		Event.POWERUP: return powerup_strength
	return 0.0


func _duration_for(event: Event) -> float:
	match event:
		Event.DEATH: return death_duration
		Event.POWERUP: return powerup_duration
	return 0.0
