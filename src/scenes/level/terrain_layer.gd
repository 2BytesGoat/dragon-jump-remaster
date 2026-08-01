@tool
extends TileMapLayer

## TileMapLayer that holds the solid terrain cells and drives a decorative
## visual layer placed on top of it. The visual layer is generated from a 2-bit
## Wang-style neighbor mask so each 16x16 visual tile blends with its neighbors.

@export var visual_layer: TileMapLayer
@export var hidden_layer: TileMapLayer

const HIDDEN_AREA_ATLAS_COORDS := Vector2i(2, 0)

## 2-bit neighbor mask lookup table (index 1..15). Index 0 is unused because a
## visual cell with no neighbors is skipped.
## Bit layout matches the original implementation:
##   bit 0: bottom-right  bit 1: bottom-left
##   bit 2: top-right     bit 3: top-left
## Each entry lists the atlas-coordinate choices for that mask.
const AUTOTILE_MAP: Array = [
	[Vector2i(0, 0)],                       		  # 0  (unused)
	[Vector2i(0, 2)],                       		  # 1
	[Vector2i(0, 1)],                       		  # 2
	[Vector2i(2, 0)],                       		  # 3
	[Vector2i(1, 0)],                       		  # 4
	[Vector2i(4, 2)],                       		  # 5
	[Vector2i(4, 1)],                       		  # 6
	[Vector2i(2, 2)],                       		  # 7
	[Vector2i(3, 2)],                       		  # 8
	[Vector2i(1, 2)],                       		  # 9
	[Vector2i(4, 0)],                       		  # 10
	[Vector2i(2, 1)],                       		  # 11
	[Vector2i(3, 1)],                       		  # 12
	[Vector2i(3, 0)],                       		  # 13
	[Vector2i(1, 1), Vector2i(0, 3), Vector2i(1, 3)]  # 14
]


## Updates the visual tile for a single terrain cell and its 2x2 neighbors.
func update_visual_tile(cell_coords: Vector2i) -> void:
	var source_id := get_cell_atlas_coords(cell_coords).x
	var update_layer = hidden_layer if source_id == 2 else visual_layer

	var directions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
	for direction in directions:
		var visual_coords: Vector2i = cell_coords + direction
		var mask := _compute_neighbor_mask(visual_coords, source_id)
		if mask == 0:
			continue

		var choices: Array = AUTOTILE_MAP[mask - 1]
		var probabilities: Array = [1.0]
		if choices.size() > 1:
			probabilities = _get_tile_probabilities(choices, visual_layer, source_id)

		var atlas_coords: Vector2i = _pick_weighted(choices, probabilities)
		update_layer.set_cell(visual_coords, source_id, atlas_coords)


func clear_visual_tiles() -> void:
	visual_layer.clear()
	hidden_layer.clear()

## Returns the visual layer's bounding rectangle as four global corner points
## in CCW order: top-left, top-right, bottom-right, bottom-left.
func get_visual_outline() -> Array[Vector2]:
	if not visual_layer:
		return []

	var rect := get_used_rect()
	if rect.size == Vector2i.ZERO:
		return []

	var min_x := rect.position.x
	var min_y := rect.position.y
	var max_x := rect.position.x + rect.size.x
	var max_y := rect.position.y + rect.size.y

	var corners: Array[Vector2] = []
	corners.append(visual_layer.to_global(visual_layer.map_to_local(Vector2(min_x, min_y))))
	corners.append(visual_layer.to_global(visual_layer.map_to_local(Vector2(max_x, min_y))))
	corners.append(visual_layer.to_global(visual_layer.map_to_local(Vector2(max_x, max_y))))
	corners.append(visual_layer.to_global(visual_layer.map_to_local(Vector2(min_x, max_y))))
	return corners


func get_visual_cell_atlas_coords(cell_coords: Vector2i) -> Vector2i:
	return visual_layer.get_cell_atlas_coords(cell_coords)


func get_visual_cell_source_id(cell_coords: Vector2i) -> int:
	return visual_layer.get_cell_source_id(cell_coords)


## Counts the four diagonal neighbors of a visual cell that belong to the same
## visual source, returning a 4-bit mask that matches the original bit ordering.
## The visual source is encoded in the terrain cell's atlas x-coordinate.
func _compute_neighbor_mask(cell_coords: Vector2i, source_id: int) -> int:
	var neighbours := []
	var directions: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]

	for direction in directions:
		var neighbor_coords: Vector2i = cell_coords + direction - Vector2i(1, 1)
		var neighbor_atlas := get_cell_atlas_coords(neighbor_coords)
		var has_neighbor := neighbor_atlas.x == source_id
		neighbours.insert(0, has_neighbor)

	var mask := 0
	for i in range(neighbours.size()):
		if neighbours[i]:
			mask += 1 << i

	return mask


## Reads the per-tile probability from the TileSetAtlasSource for a list of atlas coordinates.
func _get_tile_probabilities(atlas_coords: Array, layer: TileMapLayer, source_id: int) -> Array:
	var source := layer.tile_set.get_source(source_id)
	var probabilities: Array = []

	for coords in atlas_coords:
		var tile_data: TileData = source.get_tile_data(coords, 0)
		var probability = snapped(tile_data.probability, 0.0001) if tile_data else 1.0
		probabilities.append(probability)

	return probabilities


## Picks one item from array using the supplied weights. Falls back to the first item.
func _pick_weighted(array: Array, weights: Array = []) -> Variant:
	if array.is_empty():
		return Vector2i(-1, -1)

	if array.size() == 1:
		return array[0]

	var sum := 0.0
	for weight in weights:
		sum += weight

	var rnd := randf() * sum
	for i in range(array.size()):
		if rnd < weights[i]:
			return array[i]
		rnd -= weights[i]

	return array[0]
