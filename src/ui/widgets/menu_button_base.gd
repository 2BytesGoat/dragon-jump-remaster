extends BaseButton
class_name MenuButtonBase

## MenuButtonBase
## Shared highlight behavior for menu buttons: pops the button's scale on
## focus / hover / press. Subclasses (Button, TextureButton) inherit this
## via the signal connections made in _ready().

var _hover_tween: Tween = null


func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if not (button_pressed or disabled):
		self.grab_focus()


func _on_mouse_exited() -> void:
	self.release_focus()


func _on_focus_entered() -> void: 
	_pop_scale(1.3)


func _on_focus_exited() -> void:
	_pop_scale(1.0)


func _on_button_down() -> void:
	_pop_scale(1.0)


func _on_button_up() -> void:
	_pop_scale(1.1)


func _pop_scale(target: float) -> void:
	if _hover_tween != null and _hover_tween.is_valid():
		_hover_tween.kill()
	pivot_offset = size / 2.0
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", Vector2(target, target), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
