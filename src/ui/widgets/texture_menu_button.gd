extends MenuButtonBase
class_name TextureMenuButton

## TextureMenuButton
## Icon menu button (TextureButton). Highlight / pop-scale behavior is
## inherited from MenuButtonBase. Draws a small down-arrow above the icon
## while focused (mouse hover and keyboard/controller focus share the same
## focus path in MenuButtonBase).

const ARROW_WIDTH := 6.0
const ARROW_HEIGHT := 4.0
const ARROW_GAP := 2.0
const ARROW_COLOR := Color(1, 1, 1, 0.9)

var _arrow_visible := false


func _on_focus_entered() -> void:
	super()
	_arrow_visible = true
	queue_redraw()


func _on_focus_exited() -> void:
	super()
	_arrow_visible = false
	queue_redraw()


func _draw() -> void:
	if not _arrow_visible:
		return
	var half := ARROW_WIDTH / 2.0
	var top := -ARROW_GAP - ARROW_HEIGHT
	var points := PackedVector2Array([
		Vector2(size.x / 2.0 - half, top),
		Vector2(size.x / 2.0 + half, top),
		Vector2(size.x / 2.0, top + ARROW_HEIGHT),
	])
	draw_colored_polygon(points, ARROW_COLOR)
