@tool
class_name ParallaxAutoFit
extends Parallax2D

## Extra size multiplier over the viewport so edges stay covered during parallax.
@export var margin: float = 1.05
## How much slower this layer should move relative to the camera per axis (1.0 = same speed, 0.5 = half speed).
@export var parallax_speed: Vector2 = Vector2(0.5, 0.5):
	set(value):
		parallax_speed = value
		scroll_scale = value

@onready var _sprite: Sprite2D = _get_sprite()


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Wait for the level to compute its size before fitting.
	var level := _find_level()
	if level and level.has_signal("level_size_updated"):
		level.level_size_updated.connect(_on_level_size_updated, CONNECT_ONE_SHOT)
		# If the level is already initialized, fit immediately as well.
		if level.level_size.x > 0:
			_fit(Vector2(level.level_size))
	else:
		_fit(Vector2.ZERO)


func _on_level_size_updated(level_size: Vector2i) -> void:
	_fit(Vector2(level_size))


func _fit(level_size: Vector2) -> void:
	if _sprite == null or _sprite.texture == null:
		return
	
	var viewport_size := get_viewport().get_visible_rect().size
	var tex_size := _sprite.texture.get_size()
	
	# Uniformly scale the sprite so it fills the viewport while preserving
	# the pixel aspect ratio. Tiling (not stretching) handles parallax travel.
	var needed_scale := maxf(
		viewport_size.x / tex_size.x,
		viewport_size.y / tex_size.y
	) * margin
	_sprite.scale = Vector2(needed_scale, needed_scale)
	
	# Keep the sprite centered on the layer anchor.
	_sprite.position = Vector2.ZERO
	_sprite.offset = Vector2.ZERO
	_sprite.centered = true
	
	# Tile using the actual scaled size in both directions.
	var scaled_size := tex_size * needed_scale
	repeat_size = scaled_size
	
	# Cover viewport plus the furthest the camera can scroll in each axis.
	var camera_range := viewport_size.max(level_size)
	var parallax_shift := camera_range * Vector2(
		absf(1.0 - parallax_speed.x),
		absf(1.0 - parallax_speed.y)
	)
	var needed_coverage := viewport_size + parallax_shift * 2.0
	
	# Repeats: enough to cover the whole parallaxed viewport on both axes.
	var repeats_x := int(ceilf(needed_coverage.x / scaled_size.x)) + 1
	var repeats_y := int(ceilf(needed_coverage.y / scaled_size.y)) + 1
	repeat_times = maxi(3, maxi(repeats_x, repeats_y))
	
	# Keep default offsets; Parallax2D's modulo repeat aligns tiling.
	scroll_offset = Vector2.ZERO
	screen_offset = Vector2.ZERO


func _get_sprite() -> Sprite2D:
	for child in get_children():
		if child is Sprite2D:
			return child
	return null


func _find_level() -> Node:
	var node := get_parent()
	while node:
		if node.is_in_group("Level") or node.name == "Level":
			return node
		node = node.get_parent()
	return null
