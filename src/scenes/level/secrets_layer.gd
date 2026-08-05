@tool
extends TileMapLayer

## TileMapLayer that marks secret areas. Each secret island gets an Area2D so
## the layer fades out when the player enters and fades back in when leaving.

@export var terrain_tilemap: TileMapLayer
@onready var visual_layer: TileMapLayer = $VisualLayer

const HIDDEN_AREA_ATLAS_COORDS := Vector2i(2, 0)

# Offsets of the four visual tiles that cover one terrain cell.
const DIRECTIONS: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]


func _init_secrets() -> void:
	# Remove per-island visual layers and Area2D children from a previous init.
	# clear_level() clears the TileMapLayer's own cells but not its child nodes,
	# so without this they accumulate across level reloads and render stale tiles.
	for child in visual_layer.get_children():
		child.queue_free()
	for child in get_children():
		if child is Area2D:
			child.queue_free()

	var islands := _get_islands()
	for island in islands:
		var island_visual := _create_island_visual_layer()
		_generate_area_for_island(island, island_visual)
		_hide_secret_cells(island, island_visual)


## Creates a per-island visual TileMapLayer so each island can fade in/out
## independently instead of fading the entire secrets visual layer at once.
func _create_island_visual_layer() -> TileMapLayer:
	var layer := TileMapLayer.new()
	visual_layer.add_child(layer)
	layer.tile_set = visual_layer.tile_set
	# Position is inherited from visual_layer (the parent); setting it again
	# would double the offset (visual_layer is already at -8,-8).
	return layer


## Replaces the secret cells with hidden-area terrain tiles, autotiles the
## secret-rock visuals on the terrain visual layer, and covers them with the
## original terrain visuals on the island's own visual layer. Then clears the secret cells.
func _hide_secret_cells(cell_array: Array, island_visual: TileMapLayer) -> void:
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
		terrain_tilemap.set_cell(cell_coords, 0, HIDDEN_AREA_ATLAS_COORDS)
		self.erase_cell(cell_coords)

	# 3. Copy the captured original visuals onto this island's visual layer so it
	#    can fade out independently and reveal the terrain underneath.
	for visual_coords in original_visual_tiles:
		var tile: Dictionary = original_visual_tiles[visual_coords]
		if tile.atlas_coords == Vector2i(-1, -1):
			island_visual.erase_cell(visual_coords)
			continue

		island_visual.set_cell(visual_coords, tile.source_id, tile.atlas_coords)

	# 4. Rebuild the terrain visual layer for every secret cell. Because hidden
	#    terrain uses atlas x == 2, update_visual_tile will use the secret rock
	#    source and autotile its 2x2 visual area against neighboring hidden cells.
	for cell_coords in cell_array:
		terrain_tilemap.update_visual_tile(cell_coords)


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
## `island_visual` is the per-island visual layer that fades when entered.
func _generate_area_for_island(island: Array, island_visual: TileMapLayer) -> void:
	var area := Area2D.new()
	add_child(area)
	area.name = "Island_%d" % island.size()
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(5, true)
	area.area_entered.connect(_on_secret_area_entered.bind(island_visual))
	area.area_exited.connect(_on_secret_area_exited.bind(island_visual))

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

	# Fallback: if the merged polygon ended up empty (every merge failed), build
	# a per-cell polygon so the Area2D still has collision and the fade triggers.
	if area_poly.is_empty():
		push_warning("Secret island has no merged polygon; falling back to per-cell collision.")
		for cell in island:
			var pos := self.map_to_local(cell)
			var half := cell_size / 2.0
			var cell_polygon := CollisionPolygon2D.new()
			cell_polygon.polygon = PackedVector2Array([
				pos + Vector2(-half.x, -half.y),
				pos + Vector2(half.x, -half.y),
				pos + Vector2(half.x, half.y),
				pos + Vector2(-half.x, half.y)
			])
			area.call_deferred("add_child", cell_polygon)
	else:
		var polygon := CollisionPolygon2D.new()
		polygon.polygon = area_poly
		area.call_deferred("add_child", polygon)


func _on_secret_area_entered(_area: Area2D, island_visual: TileMapLayer) -> void:
	var tween := create_tween()
	tween.tween_property(island_visual, "modulate:a", 0.1, 0.2)


func _on_secret_area_exited(_area: Area2D, island_visual: TileMapLayer) -> void:
	var tween := create_tween()
	tween.tween_property(island_visual, "modulate:a", 1.0, 0.3)
