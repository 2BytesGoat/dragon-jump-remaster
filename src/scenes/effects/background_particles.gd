extends GPUParticles2D

## Handles level_size_updated signal to resize the emission box so particles
## cover the full level. When the signal isn't connected (e.g. menus), uses defaults.


func _ready() -> void:
	# Each instance gets its own material so we can safely modify emission box
	# without affecting other instances (menus, level select, etc.)
	if process_material:
		process_material = process_material.duplicate()


func _on_level_level_size_updated(level_size: Vector2i) -> void:
	if not process_material is ParticleProcessMaterial:
		return
	var mat := process_material as ParticleProcessMaterial
	# Emission box extents are half-widths; cover the full level
	var half_x := maxf(level_size.x / 2.0, 160.0)
	var half_y := maxf(level_size.y / 2.0, 1.0)
	mat.emission_box_extents = Vector3(half_x, half_y, 1.0)
	# Center the emitter so the box spans (0,0) to level_size (was centered at origin)
	position = Vector2(half_x, half_y)
	restart()
