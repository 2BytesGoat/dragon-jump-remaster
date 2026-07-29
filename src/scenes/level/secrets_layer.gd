@tool
extends TileMapLayer

## TileMapLayer that marks secret areas. Each secret island gets an Area2D so
## the layer fades out when the player enters and fades back in when leaving.

@export var terrain_tilemap: TileMapLayer

@onready var visual_layer: TileMapLayer = $VisualLayer


func _init_secrets() -> void:
	var islands := _get_islands()
	for island in islands:
		_generate_area_for_island(island)
		_hide_secret_cells(island)


## Replaces the secret cells with terrain tiles and copies the matching visual
## tiles onto the secrets visual layer, then clears the secret cells.
func _hide_secret_cells(cell_array: Array) -> void:
	for cell_coords in cell_array:
		var source_id := terrain_tilemap.get_cell_source_id(cell_coords)
		if source_id == -1:
			continue

		terrain_tilemap.set_tile_hidden_area(cell_coords)

		var directions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
		for direction in directions:
			var visual_coords: Vector2i = cell_coords + direction
			var atlas_coords: Vector2i = terrain_tilemap.get_visual_cell_atlas_coords(visual_coords)
			visual_layer.set_cell(visual_coords, 0, atlas_coords)

	for cell_coords in cell_array:
		self.erase_cell(cell_coords)


## Returns a list of contiguous secret cell groups using 4-way connectivity.
func _get_islands() -> Array:
	var used := self.get_used_cells()
	var visited := {}
	var islands := []

	for cell in used:
		if cell in visited:
			continue

		var island := []
		var stack: Array[Vector2i] = [cell]

		while stack:
			var current: Vector2i = stack.pop_back()
			if current in visited:
				continue
			visited[current] = true
			island.append(current)

			for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var neighbor: Vector2i = current + dir
				if neighbor in used and not neighbor in visited:
					stack.append(neighbor)

		islands.append(island)

	return islands


## Builds an Area2D + CollisionPolygon2D that covers one secret island.
func _generate_area_for_island(island: Array) -> void:
	var area := Area2D.new()
	add_child(area)
	area.name = "Island_%d" % island.size()
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(5, true)
	area.area_entered.connect(_on_secret_area_entered)
	area.area_exited.connect(_on_secret_area_exited)

	var cell_size := Vector2(self.tile_set.tile_size)
	var area_poly := PackedVector2Array()

	for cell in island:
		var pos := self.map_to_local(cell)
		var half := cell_size / 2.0
		var tile_poly := PackedVector2Array([
			pos + Vector2(-half.x, -half.y),
			pos + Vector2(half.x, -half.y),
			pos + Vector2(half.x, half.y),
			pos + Vector2(-half.x, half.y)
		])

		if area_poly.is_empty():
			area_poly = tile_poly
			continue

		var merged := Geometry2D.merge_polygons(area_poly, tile_poly)
		if merged.size() > 0:
			area_poly = merged[0]
		else:
			push_warning("Failed to merge secret island polygon for cell %s" % cell)

	var polygon := CollisionPolygon2D.new()
	polygon.polygon = area_poly
	area.add_child(polygon)


func _on_secret_area_entered(_area: Area2D) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 0.2)


func _on_secret_area_exited(_area: Area2D) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
