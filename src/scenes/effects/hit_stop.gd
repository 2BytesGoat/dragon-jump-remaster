class_name HitStop
extends Node

signal finished

@export var enabled: bool = true
@export var freeze_duration: float = 0.12
@export var slowmo_time_scale: float = 0.3
@export var slowmo_duration: float = 0.5

var _active: bool = false


func trigger() -> void:
	if not enabled or _active:
		return
	_active = true
	Engine.time_scale = 0.0
	await get_tree().create_timer(freeze_duration, true, false, true).timeout
	Engine.time_scale = slowmo_time_scale
	await get_tree().create_timer(slowmo_duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_active = false
	finished.emit()


func _exit_tree() -> void:
	if Engine.time_scale != 1.0:
		Engine.time_scale = 1.0
