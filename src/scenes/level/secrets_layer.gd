@tool
extends TileMapLayer

## TileMapLayer that marks secret areas. Each secret island gets an Area2D so
## the layer fades out when the player enters and fades back in when leaving.

@export var terrain_tilemap: TileMapLayer

@onready var visual_layer: TileMapLayer = $VisualLayer

const SECRET_VISUAL_SOURCE_ID := 2

# Offsets of the four visual tiles that cover one terrain cell.
const DIRECTIONS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]


func _init_secrets() -> void:
	var islands := _get_islands()
	for island in islands:
		_generate_area_for_island(island)
		_hide_secret_cells(island)


## Replaces the secret cells with terrain tiles, hides the secret-rock visuals
## on the terrain visual layer, and covers them with the original terrain
## visuals on the secrets visual layer. Then clears the secret cells.
func _hide_secret_cells(cell_array: Array) -> void:
	# 1. Capture original terrain visuals for every visual cell touched by the
	#    secret island, before any terrain cell is modified.
	var original_visual_tiles: Dictionary[Vector2i, Dictionary] = {}
	for cell_coords in cell_array:
		for direction in DIRECTIONS:
			var visual_coords: Vector2i = cell_coords + direction
			if visual_coords in original_visual_tiles:
				continue

			var atlas_coords: Vector2i = terrain_tilemap.get_visual_cell_atlas_coords(visual_coords)
			var source_id: int = terrain_tilemap.get_visual_cell_source_id(visual_coords)
			original_visual_tiles[visual_coords] = {source_id = source_id, atlas_coords = atlas_coords}

	# 2. Hide all secret cells: terrain becomes solid. This may update the
	#    terrain visual layer, but we will overwrite those changes next.
	for cell_coords in cell_array:
		var terrain_source_id := terrain_tilemap.get_cell_source_id(cell_coords)
		if terrain_source_id == -1:
			continue
		terrain_tilemap.set_tile_hidden_area(cell_coords)
		self.erase_cell(cell_coords)

	# 3. Copy the captured original visuals onto the secrets visual layer and
	#    switch the terrain visual layer to the secret rock atlas. This must be
	#    a single pass so the secrets layer never copies a source-2 tile.
	for visual_coords in original_visual_tiles:
		var tile: Dictionary = original_visual_tiles[visual_coords]
		if tile.atlas_coords == Vector2i(-1, -1):
			visual_layer.erase_cell(visual_coords)
			continue

		visual_layer.set_cell(visual_coords, tile.source_id, tile.atlas_coords)
		terrain_tilemap.set_visual_tile(visual_coords, SECRET_VISUAL_SOURCE_ID, tile.atlas_coords)


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
