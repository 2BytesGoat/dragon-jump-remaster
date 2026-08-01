extends GPUParticles2D

## Handles level_size_updated signal to resize the emission box so particles
## cover the full level. When the signal isn't connected (e.g. menus), uses defaults.


func _enter_tree() -> void:
	# Duplicate the shared material as early as possible so level_size_updated
	# handlers (which may fire before _ready) modify this instance's own copy.
	if process_material:
		process_material = process_material.duplicate()
		

func _on_level_level_size_updated(level_size: Vector2i) -> void:
	if not process_material is ParticleProcessMaterial:
		return
	var mat := process_material as ParticleProcessMaterial
	# Emission box extents are half-widths; cover the full level
	var half_x := maxf(level_size.x / 2.0, 160.0)
	var half_y := maxf(level_size.y / 2.0, 1.0)
	# Account for emitter scale so particles actually cover the level in world space
	var safe_scale := Vector2(maxf(scale.x, 0.001), maxf(scale.y, 0.001))
	mat.emission_box_extents = Vector3(half_x, half_y, 1.0) / Vector3(safe_scale.x, safe_scale.y, 1.0)
	# Center the emitter so the box spans (0,0) to level_size
	position = Vector2(half_x, half_y) / safe_scale
	restart()
