extends Polygon2D

## Wall thickness in pixels (2x level tile size). Level tile is typically 16px.
const WALL_THICKNESS_MULTIPLIER := 10
const DEFAULT_TILE_SIZE := 16


func _on_level_level_outline_updated(level_outline: Array) -> void:
	if level_outline.size() < 3:
		return

	var tile_size := _get_tile_size()

	# Convert from global (viewport) space to this node's local space
	var raw: Array[Vector2] = []
	for p in level_outline:
		raw.append(to_local(Vector2(p)))

	var inner = _expand_ring(raw, -tile_size * 0.4)
	var outer = _expand_ring(raw, tile_size * WALL_THICKNESS_MULTIPLIER)

	var donut: PackedVector2Array = PackedVector2Array()
	for p in outer:
		donut.append(p)
	
	donut.append(outer[0])
	donut.append(inner[0])
	
	inner.reverse()
	for p in inner:
		donut.append(p)
	
	polygon = donut


func _expand_ring(points: Array[Vector2], distance: float) -> Array[Vector2]:
	var result: Array[Vector2] = [
		points[0] + Vector2(-distance, -distance),
		points[1] + Vector2(+distance, -distance),
		points[2] + Vector2(+distance, +distance),
		points[3] + Vector2(-distance, +distance),
	]
	return result


func _get_tile_size() -> float:
	var level := get_parent()
	if level is Level:
		var layer: TileMapLayer = level.terrain_layer
		if layer and layer.tile_set:
			var ts := layer.tile_set
			if ts.get_source_count() > 0:
				var source = ts.get_source(0)
				if source is TileSetAtlasSource:
					return float(source.texture_region_size.x)
	return DEFAULT_TILE_SIZE
