extends Polygon2D

## Renders a thick outline/blend around the rectangular level perimeter so
## walls fade into the background. Expects the level outline to be a quad in
## CCW order: top-left, top-right, bottom-right, bottom-left.

const WALL_THICKNESS_MULTIPLIER := 10
const DEFAULT_TILE_SIZE := 16


func _on_level_level_outline_updated(level_outline: Array) -> void:
	if level_outline.size() < 4:
		push_warning("LevelWallBlend: expected 4 outline corners, got %d" % level_outline.size())
		return

	var tile_size := _get_tile_size()
	var local_outline: Array[Vector2] = []
	for point in level_outline:
		local_outline.append(to_local(Vector2(point)))

	var inner := _expand_ring(local_outline, -tile_size * 0.4)
	var outer := _expand_ring(local_outline, tile_size * WALL_THICKNESS_MULTIPLIER)

	var donut := PackedVector2Array()
	for point in outer:
		donut.append(point)

	# Close the outer ring and connect to the inner ring.
	donut.append(outer[0])
	donut.append(inner[0])

	inner.reverse()
	for point in inner:
		donut.append(point)

	polygon = donut


## Offsets each corner of a rectangular ring by distance along both axes.
func _expand_ring(points: Array[Vector2], distance: float) -> Array[Vector2]:
	return [
		points[0] + Vector2(-distance, -distance),
		points[1] + Vector2(+distance, -distance),
		points[2] + Vector2(+distance, +distance),
		points[3] + Vector2(-distance, +distance),
	]


func _get_tile_size() -> float:
	var level := get_parent()
	if level is Level:
		var layer: TileMapLayer = level.terrain_layer
		if layer and layer.tile_set and layer.tile_set.get_source_count() > 0:
			var source = layer.tile_set.get_source(0)
			if source is TileSetAtlasSource:
				return float(source.texture_region_size.x)

	return DEFAULT_TILE_SIZE
