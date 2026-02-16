extends Camera2D

@export var player_node: Node2D
@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()

var noise_i: float = 0.0
var noise_seed: float = 30.0

var shake_decay_rate: float = 3.0
var shake_strength: float = 0.0

var initial_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	initial_offset = self.offset


func _process(delta: float) -> void:
	if shake_strength <= 1:
		return
	
	shake_strength = snapped(lerp(shake_strength, 0.0, shake_decay_rate * delta), 0.01)
	var shake_offset = get_random_offset()
	self.offset = initial_offset + shake_offset
	
	if shake_strength <= 1:
		self.offset = initial_offset


func _physics_process(_delta: float) -> void:
	if player_node == null:
		return
	
	global_position = global_position.lerp(player_node.global_position, 0.15)


func zoom_on(target_position: Vector2, zoom_factor: float = 5.0):
	position = target_position
	zoom = Vector2(zoom_factor, zoom_factor)


func apply_shake(strength: float = 30):
	noise_i = 0.0
	shake_strength = strength


func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)


func _on_level_level_size_updated(level_size: Vector2i) -> void:
	global_position = Vector2(level_size) * Vector2(0.5, 0.5)
	
	var padding = 16
	limit_left = -padding * 3
	limit_right = level_size.x + padding * 3
	limit_bottom = level_size.y + padding


func _on_level_level_size_updated_w_zoom(level_size: Vector2i) -> void:
	var viewport_size = get_viewport().size
	
	var scale_x = float(level_size.x) / (viewport_size.x * 0.85)
	var scale_y = float(level_size.y) / (viewport_size.y * 0.85)
	
	var new_scale = max(scale_x, scale_y)
	var new_zoom = 1.0 / new_scale
	zoom = Vector2(new_zoom, new_zoom)
	
	self.global_position = level_size / 2 - viewport_size / 2 + Vector2i(8, 0)
