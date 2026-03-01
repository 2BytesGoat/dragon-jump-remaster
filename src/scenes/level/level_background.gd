extends Polygon2D

var height_scale = 400
var time_scale = 10

#@onready var particles: GPUParticles2D = $GPUParticles2D

#func update_particles(max_x, max_y):
	#particles.visibility_rect = Rect2(-10, -10, max_x + 10, max_y + 10)
	#particles.process_material.emission_shape_scale = Vector3(max_x, max_y, 1)


func _on_level_level_outline_updated(level_outline: Array) -> void:
	polygon = level_outline
	
	var max_x = 0
	var max_y = 0
	for point in level_outline:
		max_x = max(point.x, max_x)
		max_y = max(point.y, max_y)
