extends Camera2D

var viewport_size = Vector2i(640, 480)


func _on_level_level_size_updated(level_size: Vector2i) -> void:
	var scale_x = float(level_size.x) / (viewport_size.x * 0.9)
	var scale_y = float(level_size.y) / (viewport_size.y * 0.9)
	
	var new_scale = max(scale_x, scale_y)
	var new_zoom = 1.0 / new_scale
	zoom = Vector2(new_zoom, new_zoom)
	
	self.global_position = level_size / 2 - viewport_size / 2 + Vector2i(8, 0)
