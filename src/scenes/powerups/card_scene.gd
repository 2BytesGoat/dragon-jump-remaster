class_name CardUI
extends Control

const POWERUP_DISPLAY_NAMES := {
	"DoubleJump": "BOOST",
	"Dash": "DASH",
	"Grapple": "HOOK",
	"Stomp": "STOMP",
}

@onready var container: MarginContainer = $MarginContainer
@onready var texture: TextureRect = $MarginContainer/CardTexture
@onready var label_top: Label = %CardLabel_TopLeft
@onready var label_bottom: Label = %CardLabel_BottomRight
@onready var _palette: PowerupPalette = Constants.POWERUP_PALETTE

@export var container_scale_single_player: Vector2 = Vector2.ONE
@export var container_scale_split_screen: Vector2 = Vector2(0.75, 0.75)

@export var draw_duration: float = 0.6
@export var dissolve_duration: float = 0.35
@export var dissolve_pop_offset: Vector2 = Vector2(-12, -18)
@export var dissolve_pop_duration: float = 0.2
@export var position_curve: Curve
@export var scale_curve: Curve
@export var fade_curve: Curve
@export var start_scale: Vector2 = Vector2(0.15, 0.15)
@export var draw_start_offset: Vector2 = Vector2(-40, -45)

var is_splitscreen: bool = false
var powerup_type: String = ""
var container_scale: Vector2

var _draw_progress: float = -1.0
var _draw_start_position: Vector2
var _draw_end_position: Vector2

var is_dissolving: bool = false
var has_drawn: bool = false
var _draw_tween: Tween = null
var _dissolve_tween: Tween = null


func _ready() -> void:
	if not is_splitscreen:
		container_scale = container_scale_single_player
	else:
		container_scale = container_scale_split_screen
 

func _process(delta: float) -> void:
	if _draw_progress < 0.0:
		return
	
	_draw_progress += delta / draw_duration
	if _draw_progress >= 1.0:
		_draw_progress = 1.0
		set_process(false)
		has_drawn = true
	
	var position_t := position_curve.sample_baked(_draw_progress) if position_curve else _draw_progress
	var scale_t := scale_curve.sample_baked(_draw_progress) if scale_curve else _draw_progress
	var fade_t := fade_curve.sample_baked(_draw_progress) if fade_curve else _draw_progress
	
	container.position = _draw_start_position.lerp(_draw_end_position, position_t)
	container.scale = start_scale.lerp(container_scale, scale_t)
	container.modulate.a = fade_t


func _stop_draw_animation() -> void:
	_draw_progress = -1.0
	set_process(false)
	if _draw_tween != null and _draw_tween.is_valid():
		_draw_tween.kill()
		_draw_tween = null


func draw(type: String, exists: bool = false, from_position: Vector2 = Vector2.ZERO) -> void:
	powerup_type = type
	var display_name = POWERUP_DISPLAY_NAMES.get(type, type.to_upper())
	label_top.text = display_name
	label_bottom.text = display_name
	label_top.self_modulate.a = 1.0
	label_bottom.self_modulate.a = 1.0
	texture.self_modulate = _palette.get_color(type)
	
	if not exists:
		play_draw_new_animation(from_position)
	else:
		play_draw_same_animation()


func shift_by(offsets: Array):
	if is_dissolving:
		return
	
	var margin_names := [
		"margin_left",
		"margin_top",
		"margin_right",
		"margin_bottom"
		]
	
	for i in range(4):
		var current = container.get_theme_constant(margin_names[i])
		var new_value = current + offsets[i]
		container.add_theme_constant_override(margin_names[i], new_value)


func play_draw_new_animation(pickup_position: Vector2 = Vector2.ZERO):
	if pickup_position != Vector2.ZERO:
		var pickup_local: Vector2 = _to_card_local(pickup_position)
		_draw_start_position = pickup_local
	else:
		_draw_start_position = Vector2(self.size.x * 0.5, self.size.y * 0.5) + draw_start_offset
	_draw_end_position = Vector2(0.0, self.size.y + container.offset_top)
	
	container.position = _draw_start_position
	container.scale = start_scale
	container.rotation = 0.0
	container.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	_draw_progress = 0.0
	set_process(true)


func _to_card_local(pickup_position: Vector2) -> Vector2:
	var sub_viewport := _find_gameplay_sub_viewport()
	if sub_viewport == null:
		return self.get_global_transform().affine_inverse() * pickup_position
	
	# pickup_position is in the SubViewport's world/canvas space.
	# Convert it to the SubViewport's viewport coordinates (i.e. where it appears
	# on the rendered sub-viewport), which map 1:1 to the root viewport's canvas
	# coordinates where this card UI lives.
	var viewport_position: Vector2 = sub_viewport.get_canvas_transform() * pickup_position
	return self.get_global_transform().affine_inverse() * viewport_position


func _find_gameplay_sub_viewport() -> SubViewport:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return null
	
	var sub_viewport_container := current_scene.get_node_or_null("SubViewportContainer")
	if sub_viewport_container == null:
		return null
	
	for child in sub_viewport_container.get_children():
		if child is SubViewport:
			return child
	
	return null


func play_draw_same_animation():
	var target_y := self.size.y + container.offset_top
	
	container.position = Vector2(-20.0, target_y)
	container.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	container.scale = container_scale
	container.rotation = 0.0
	
	if _draw_tween != null and _draw_tween.is_valid():
		_draw_tween.kill()
	
	_draw_tween = self.create_tween()
	_draw_tween.set_ease(Tween.EASE_OUT)
	_draw_tween.set_trans(Tween.TRANS_CUBIC)
	_draw_tween.tween_property(container, "position", Vector2(0.0, target_y), 0.35)
	_draw_tween.parallel().tween_property(container, "self_modulate", Color.WHITE, 0.35)
	if fade_curve:
		_draw_tween.parallel().tween_method(
			func(value: float) -> void: container.self_modulate.a = value,
			0.0,
			1.0,
			0.35
		)
	_draw_tween.finished.connect(func() -> void:
		has_drawn = true
		_draw_tween = null
	, CONNECT_ONE_SHOT)


func dissolve_out(on_finished: Callable = Callable()) -> void:
	is_dissolving = true
	
	# Stop any active draw animation or tween before dissolving.
	_stop_draw_animation()
	
	# If the card hasn't finished drawing, there is nothing to dissolve; remove it.
	if not has_drawn:
		if on_finished.is_valid():
			on_finished.call()
		return
	
	var material := texture.material as ShaderMaterial
	if material == null:
		if on_finished.is_valid():
			on_finished.call()
		return
	
	# Start the burn from the center of the card in UV space.
	material.set_shader_parameter("position", Vector2(0.5, 0.5))
	material.set_shader_parameter("radius", 0.0)
	
	if _dissolve_tween != null and _dissolve_tween.is_valid():
		_dissolve_tween.kill()
	
	_dissolve_tween = create_tween()
	var tween := _dissolve_tween
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Pop up and to the left while dissolving.
	tween.parallel().tween_property(
		container,
		"position",
		container.position + dissolve_pop_offset,
		dissolve_pop_duration
	)
	
	# Dissolve the card textures.
	tween.parallel().tween_method(
		func(value: float) -> void: material.set_shader_parameter("radius", value),
		0.0,
		1.5,
		dissolve_duration
	)
	
	# Fade the labels out quickly so they don't linger.
	tween.parallel().tween_property(label_top, "self_modulate:a", 0.0, dissolve_duration * 0.4)
	tween.parallel().tween_property(label_bottom, "self_modulate:a", 0.0, dissolve_duration * 0.4)
	
	tween.finished.connect(func() -> void:
		_dissolve_tween = null
		if on_finished.is_valid():
			on_finished.call()
	, CONNECT_ONE_SHOT)
