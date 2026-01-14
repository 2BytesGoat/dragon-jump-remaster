extends Camera2D


func _on_level_level_size_updated(level_size: Vector2i) -> void:
	var scale_x = float(level_size.x) / 512
	var scale_y = float(level_size.y) / 512
	var new_scale = max(scale_x, scale_y)
	var new_zoom = 1.0 / new_scale
	zoom = Vector2(new_zoom, new_zoom)
	
	self.global_position = level_size / 2 - Vector2i(320, 240)
