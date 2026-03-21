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

	var count := raw.size()

	# Expand outward: inner at boundary, outer beyond (negate: normals point inward for CCW)
	var inner := _expand_ring(raw, -tile_size * 0.15)  # Just outside the boundary
	var outer := _expand_ring(raw, -tile_size * WALL_THICKNESS_MULTIPLIER)  # Further out for border thickness

	var donut: PackedVector2Array = PackedVector2Array()
	for p in outer:
		donut.append(p)
	
	donut.append(outer[0])
	donut.append(inner[0])

	for i in range(count - 1, -1, -1):
		donut.append(inner[i])

	polygon = donut


func _expand_ring(points: Array[Vector2], distance: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var n := points.size()
	for i in n:
		var prev := points[(i - 1 + n) % n]
		var curr := points[i]
		var next := points[(i + 1) % n]
		var edge_a := (curr - prev).normalized()
		var edge_b := (next - curr).normalized()
		var normal_a := Vector2(edge_a.y, -edge_a.x)
		var normal_b := Vector2(edge_b.y, -edge_b.x)
		var miter := (normal_a + normal_b).normalized()
		var raw_length = distance / max(miter.dot(normal_a), 0.1)
		var miter_length = clamp(raw_length, min(distance, distance * 4.0), max(distance, distance * 4.0))
		result.append(curr + miter * miter_length)
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
