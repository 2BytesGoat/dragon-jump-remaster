extends Node

## SceneLoader
## Handles scene changes with a fade overlay and error reporting.

const FADE_DURATION_SECONDS := 0.5

var scene_data := {}

var _canvas_layer: CanvasLayer
var _overlay: ColorRect
var _tween: Tween
var _pending_path: String = ""


func _ready() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 128
	_canvas_layer.visible = false
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_layer.add_child(_overlay)
	add_child(_canvas_layer)


func go_to(scene_path: String, data: Dictionary = {}) -> void:
	scene_data = data
	_pending_path = scene_path
	# Defer the scene change so any pending input event is fully processed
	# before the old viewport/SubViewport leaves the scene tree.
	call_deferred("_start_transition")


func _start_transition() -> void:
	if _canvas_layer == null or _overlay == null:
		push_warning("SceneLoader: overlay not ready; changing scene without transition.")
		_change_scene(_pending_path)
		return

	_canvas_layer.visible = true
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(_overlay, "color", Color(0.0, 0.0, 0.0, 1.0), FADE_DURATION_SECONDS)
	_tween.finished.connect(_on_fade_in_finished)


func _on_fade_in_finished() -> void:
	_change_scene(_pending_path)


func _change_scene(scene_path: String) -> void:
	var tree := get_tree()
	if tree == null:
		push_error("SceneLoader: scene tree is null; cannot change scene to '%s'" % scene_path)
		_fade_out()
		return

	var err := tree.change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneLoader: failed to change scene to '%s' (error %s)" % [scene_path, err])
		_fade_out()
		return
	call_deferred("_fade_out")


func _fade_out() -> void:
	if _canvas_layer == null or _overlay == null:
		return
	_kill_tween()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_property(_overlay, "color", Color(0.0, 0.0, 0.0, 0.0), FADE_DURATION_SECONDS)
	_tween.finished.connect(_on_fade_out_finished)


func _on_fade_out_finished() -> void:
	if _canvas_layer != null:
		_canvas_layer.visible = false


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
