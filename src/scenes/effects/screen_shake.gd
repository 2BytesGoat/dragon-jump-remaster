class_name ScreenShake
extends Node

enum Event { DEATH, STOMP, DASH, LAND }

@export var enabled: bool = true
@export var camera: Camera2D
@export var death_strength: float = 30.0
@export var stomp_strength: float = 18.0
@export var dash_strength: float = 12.0
@export var land_strength: float = 8.0

@export var death_duration: float = 0.4
@export var stomp_duration: float = 0.2
@export var dash_duration: float = 0.15
@export var land_duration: float = 0.1


func shake(event: Event) -> void:
	if not enabled or camera == null:
		return
	camera.apply_shake(_strength_for(event), _duration_for(event))


func _strength_for(event: Event) -> float:
	match event:
		Event.DEATH: return death_strength
		Event.STOMP: return stomp_strength
		Event.DASH:  return dash_strength
		Event.LAND:  return land_strength
	return 0.0


func _duration_for(event: Event) -> float:
	match event:
		Event.DEATH: return death_duration
		Event.STOMP: return stomp_duration
		Event.DASH:  return dash_duration
		Event.LAND:  return land_duration
	return 0.0
