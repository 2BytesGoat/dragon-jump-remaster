extends Button
class_name CustomMenuButton

var _hover_tween: Tween = null
var _press_tween: Tween = null


func _on_mouse_entered() -> void:
	if not (button_pressed or disabled):
		self.grab_focus()


func _on_mouse_exited() -> void:
	self.release_focus()


func _on_focus_entered() -> void:
	_pop_scale(1.08)


func _on_focus_exited() -> void:
	_pop_scale(1.0)


func _on_button_down() -> void:
	_pop_scale(0.92)


func _on_button_up() -> void:
	_pop_scale(1.08)


func _pop_scale(target: float) -> void:
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	if _press_tween != null and _press_tween.is_valid():
		_press_tween.kill()
	pivot_offset = size / 2.0
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", Vector2(target, target), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
