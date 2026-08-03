class_name TransitionWipe
extends ColorRect

signal covered
signal revealed
signal reveal_midpoint
signal cover_midpoint

const _FALLBACK_DURATION := 0.2

var _tween: Tween
var is_covered: bool = false


func _ready() -> void:
	visible = false
	_set_progress(0.0)


func cover(duration: float = -1.0) -> void:
	var dur := _FALLBACK_DURATION if duration < 0.0 else duration
	_kill_tween()
	visible = true
	_set_reveal(false)
	_set_progress(0.0)
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_set_progress, 0.0, 1.0, dur)
	_tween.parallel().tween_callback(cover_midpoint.emit).set_delay(dur * 0.7)
	await _tween.finished
	is_covered = true
	covered.emit()


func reveal(duration: float = -1.0) -> void:
	var dur := _FALLBACK_DURATION if duration < 0.0 else duration
	_kill_tween()
	is_covered = false
	visible = true
	_set_reveal(true)
	_set_progress(0.0)
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_method(_set_progress, 0.0, 1.0, dur)
	_tween.parallel().tween_callback(reveal_midpoint.emit).set_delay(dur * 0.3)
	await _tween.finished
	_on_reveal_finished()


func _on_reveal_finished() -> void:
	_set_progress(0.0)
	_set_reveal(false)
	visible = false
	revealed.emit()


func _set_progress(value: float) -> void:
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("progress", value)


func _set_reveal(value: bool) -> void:
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("reveal", value)


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
