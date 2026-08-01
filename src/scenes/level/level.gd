@tool
class_name Level
extends Node2D

## The Level node builds, updates, and queries a 2D tile-based level.
##
## It owns four logical tile layers (terrain, static hazards/objects, dynamic
## objects, secrets) plus their visual counterparts. The actual tile metadata is
## stored in TileRegistry so Level, LevelCodeParser, and future systems can share
## a single source of truth without cyclic dependencies.

const LEVEL_GD_PATH := "res://src/scenes/level/level.gd"
const TMP_PREVIEW_PATH := "res://resources/level_data/tmp.tres"

const _TileRegistry := preload("res://src/scripts/resources/tile_registry.gd")
const _GRASS_SCENE := preload("res://src/scenes/level/tiles/grass.tscn")

const _EMPTY_SYMBOL := _TileRegistry.EMPTY_SYMBOL
const _WALL_SYMBOL := _TileRegistry.WALL_SYMBOL
const _SECRET_SYMBOL := _TileRegistry.SECRET_SYMBOL
const _SPIKES_SYMBOL := _TileRegistry.SPIKES_SYMBOL
const _PLAYER_SYMBOL := _TileRegistry.PLAYER_SYMBOL
const _EXIT_SYMBOL := _TileRegistry.EXIT_SYMBOL
const _SEPARATOR_SYMBOL := _TileRegistry.SEPARATOR_SYMBOL

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

@export var terrain_layer: TileMapLayer
@export var static_layer: TileMapLayer
@export var objects_layer: TileMapLayer
@export var secrets_layer: TileMapLayer
@export var terrain_visual_layer: TileMapLayer
@export var secrets_visual_layer: TileMapLayer
@export var decorations_layer: Node2D

## Chance (0.0-1.0) to spawn decorative grass on each exposed top terrain edge.
@export_range(0.0, 1.0) var grass_density: float = 0.4

## Editor-only buttons. Toggling any of them performs an action and resets.
@export var refresh_editor_preview: bool = false:
	get = _get_refresh_editor_preview,
	set = _set_refresh_editor_preview

@export var export_level_code_to_clipboard: bool = false:
	get = _get_export_level_code_to_clipboard,
	set = _set_export_level_code_to_clipboard

@export var export_level_code_to_level_script: bool = false:
	get = _get_export_level_code_to_level_script,
	set = _set_export_level_code_to_level_script

@export var export_level_code_to_tmp_preview: bool = false:
	get = _get_export_level_code_to_tmp_preview,
	set = _set_export_level_code_to_tmp_preview

# ---------------------------------------------------------------------------
# Public state
# ---------------------------------------------------------------------------

var objects_map: Dictionary = {}
var player_start_position: Vector2 = Vector2.ZERO
var populated_cells: Dictionary = {}

var exit_global_position: Vector2 = Vector2.ZERO

signal level_size_updated(level_size: Vector2i)
signal level_outline_updated(level_outline: Array)

# ---------------------------------------------------------------------------
# Private state
# ---------------------------------------------------------------------------

var _registry: _TileRegistry = _TileRegistry.default()
var _tile_names: Array[String] = []

var _is_initialized: bool = false
var _terrain_layer_used_cells: Array = []
var _current_level_code: String = ""
var _current_level_data: CampaignLevelData = null

var _level_width_cell: int = 0
var _level_height_cell: int = 0

## Pixel size of the level, updated after loading a level code. Public so
## parallax/background layers can size themselves before the first signal.
var level_size: Vector2 = Vector2.ZERO

var _flow_field: Array = []

# Runtime reverse lookup: atlas coordinate -> symbol.
var _static_atlas_coords_to_symbol: Dictionary = {}
var _object_atlas_coords_to_symbol: Dictionary = {}

# Backing state for editor-only export buttons.
var _refresh_editor_preview: bool = false
var _export_level_code_to_clipboard: bool = false
var _export_level_code_to_level_script: bool = false
var _export_level_code_to_tmp_preview: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_process(true)


func _exit_tree() -> void:
	set_process(false)


func _ready() -> void:
	add_to_group("Level")

	for info in _registry.get_names():
		_tile_names.append(info)

	_init_atlas_symbol_mapping()
	
	#var level_name = "1-4"
	#var level_data := CampaignLevelLibrary.get_level(level_name)
	#load_level(level_data)

	if Engine.is_editor_hint():
		_init_terrain_layer()
		force_rebuild_populated_cells()
		_is_initialized = true
		return

	clear_level()
	_is_initialized = true

	_init_terrain_layer()
	_update_static_alt_tiles()
	_populate_objects()
	_init_hidden_areas()
	_spawn_decoration_grass()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and _is_initialized:
		return

	_init_terrain_layer()


# ---------------------------------------------------------------------------
# Public API: loading
# ---------------------------------------------------------------------------

func load_level(level_data: CampaignLevelData) -> void:
	if level_data == null:
		push_error("Level.load_level called with null CampaignLevelData")
		return
	if _current_level_data == level_data:
		return

	_current_level_data = level_data
	update_level(level_data.code)


func update_level(level_code: String) -> void:
	if level_code.is_empty() or _current_level_code == level_code:
		return

	clear_level()
	_build_level_from_code(level_code)
	_init_terrain_layer()

	if Engine.is_editor_hint():
		force_rebuild_populated_cells()
		_current_level_code = level_code
		return

	_populate_objects()
	_init_hidden_areas()
	_update_static_alt_tiles()
	_spawn_decoration_grass()
	_current_level_code = level_code


func clear_level() -> void:
	for layer: TileMapLayer in [terrain_layer, static_layer, objects_layer, secrets_layer, terrain_visual_layer, secrets_visual_layer]:
		if layer:
			layer.clear()

	if not Engine.is_editor_hint() and objects_layer:
		for child in objects_layer.get_children():
			objects_layer.remove_child(child)
			child.queue_free()

	if not Engine.is_editor_hint() and decorations_layer:
		for child in decorations_layer.get_children():
			decorations_layer.remove_child(child)
			child.queue_free()

	objects_map = {}
	populated_cells = {}
	_current_level_data = null


func set_level(level_code: String) -> void:
	update_level(level_code)


# ---------------------------------------------------------------------------
# Public API: level code
# ---------------------------------------------------------------------------

func get_level_code() -> String:
	if not terrain_layer:
		return ""

	if Engine.is_editor_hint() or populated_cells.is_empty():
		force_rebuild_populated_cells()

	var bounds := _compute_used_bounds()
	if bounds.size == Vector2i.ZERO:
		return ""

	level_size = Vector2(bounds.size)
	var shift := Vector2i(bounds.position)

	var current_symbol := _EMPTY_SYMBOL
	var current_count := 0
	var level_code := ""

	for y in range(bounds.size.y):
		for x in range(bounds.size.x):
			var cell_coords := Vector2i(x, y) + shift
			var cell_symbol := get_cell_symbol(cell_coords)

			if cell_symbol != current_symbol:
				if current_count > 0:
					level_code += "%s%s" % [current_symbol, current_count]
				current_symbol = cell_symbol
				current_count = 0

			current_count += 1

		if current_count > 0:
			level_code += "%s%s" % [current_symbol, current_count]

		if y < bounds.size.y - 1:
			level_code += _SEPARATOR_SYMBOL

		current_count = 0

	return level_code


func get_level_size_cell() -> Vector2i:
	return Vector2i(_level_width_cell, _level_height_cell)


# ---------------------------------------------------------------------------
# Public API: queries
# ---------------------------------------------------------------------------

func get_level_costs() -> Array:
	var costs: Array = []
	for x in range(_level_width_cell):
		var row_costs: Array = []
		for y in range(_level_height_cell):
			var cell_type := get_cell_symbol(Vector2i(x, y))
			var cell_cost := 1.0
			if cell_type in [_WALL_SYMBOL, _SPIKES_SYMBOL]:
				cell_cost = INF
			row_costs.append(cell_cost)
		costs.append(row_costs)
	return costs


func get_exit_cell_coords() -> Vector2i:
	return terrain_layer.local_to_map(to_local(exit_global_position))


func get_cell_symbol(cell_coords: Vector2i) -> String:
	return populated_cells.get(cell_coords, _EMPTY_SYMBOL)


func get_cell_symbol_index(cell_coords: Vector2i) -> int:
	var cell_symbol := get_cell_symbol(cell_coords)
	return _registry.get_symbols().find(cell_symbol)


func get_surrounding_cells(global_pos: Vector2, radius: int) -> Array:
	var center_tile := terrain_layer.local_to_map(to_local(global_pos))
	var grid_data: Array = []

	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var coords := center_tile + Vector2i(x, y)
			grid_data.append(get_cell_symbol_index(coords))

	return grid_data


func get_tile_names() -> Array:
	return _tile_names.duplicate()


func get_flowfield_value(object_global_position: Vector2) -> float:
	if _flow_field.is_empty():
		push_warning("Undefined Flow Field: Returning default value 0")
		return 0.0

	var cell_coords := terrain_layer.local_to_map(to_local(object_global_position))
	if not _is_cell_in_bounds(cell_coords):
		return INF
	return _flow_field[cell_coords.x][cell_coords.y]


func reset_objects() -> void:
	for obj_type in objects_map:
		for obj in objects_map[obj_type]:
			if obj.has_method("reset"):
				obj.call_deferred("reset")


# ---------------------------------------------------------------------------
# Editor export tools
# ---------------------------------------------------------------------------

func force_rebuild_populated_cells() -> void:
	populated_cells = {}
	if not terrain_layer:
		return

	_init_atlas_symbol_mapping()

	for cell in terrain_layer.get_used_cells():
		_add_to_populated_cells(cell, _WALL_SYMBOL)

	if static_layer:
		for cell in static_layer.get_used_cells():
			var symbol := _get_cell_atlas_symbol(cell, _TileRegistry.TileType.STATIC)
			if symbol != _EMPTY_SYMBOL:
				_add_to_populated_cells(cell, symbol)

	if objects_layer:
		for cell in objects_layer.get_used_cells():
			var symbol := _get_cell_atlas_symbol(cell, _TileRegistry.TileType.OBJECT)
			if symbol != _EMPTY_SYMBOL:
				_add_to_populated_cells(cell, symbol)

	if secrets_layer:
		for cell in secrets_layer.get_used_cells():
			_add_to_populated_cells(cell, _SECRET_SYMBOL)


func _export_level_code_to_level_gd() -> void:
	var level_code := get_level_code()
	if level_code.is_empty():
		push_warning("Level code is empty, nothing to export.")
		return

	var file := FileAccess.open(LEVEL_GD_PATH, FileAccess.READ)
	if not file:
		push_error("Could not open %s for reading." % LEVEL_GD_PATH)
		return
	var script_text := file.get_as_text()
	file.close()

	var regex := RegEx.new()
	regex.compile(r"update_level\(\s*\".*?\"\s*\)")
	var result := regex.search(script_text)
	if not result:
		push_error("Could not find update_level(\"...\") call in %s" % LEVEL_GD_PATH)
		return

	var escaped := level_code.replace("\\", "\\\\").replace("\"", "\\\"")
	var replacement := "update_level(\"%s\")" % escaped
	var new_text := script_text.substr(0, result.get_start()) + replacement + script_text.substr(result.get_end())

	var out := FileAccess.open(LEVEL_GD_PATH, FileAccess.WRITE)
	if not out:
		push_error("Could not open %s for writing." % LEVEL_GD_PATH)
		return
	out.store_string(new_text)
	out.close()

	DisplayServer.clipboard_set(level_code)
	print("Updated update_level(...) in %s and copied code to clipboard." % LEVEL_GD_PATH)


func _save_level_code_to_tmp_preview() -> void:
	var level_code := get_level_code()
	if level_code.is_empty():
		push_warning("Level code is empty, nothing to export.")
		return

	var preview := CampaignLevelData.new()
	preview.level_id = "tmp"
	preview.display_name = "Temporary Editor Level"
	preview.code = level_code
	preview.times = []
	preview.hidden = true

	var err := ResourceSaver.save(preview, TMP_PREVIEW_PATH)
	if err != OK:
		push_error("Failed to save editor preview to %s (error %d)" % [TMP_PREVIEW_PATH, err])
		return

	print("Editor preview saved to %s (%d chars)" % [TMP_PREVIEW_PATH, level_code.length()])


# ---------------------------------------------------------------------------
# Editor trigger getters/setters
# ---------------------------------------------------------------------------

func _get_refresh_editor_preview() -> bool:
	return _refresh_editor_preview


func _set_refresh_editor_preview(value: bool) -> void:
	if value and Engine.is_editor_hint():
		_init_terrain_layer()
		force_rebuild_populated_cells()
	_refresh_editor_preview = false


func _get_export_level_code_to_clipboard() -> bool:
	return _export_level_code_to_clipboard


func _set_export_level_code_to_clipboard(value: bool) -> void:
	if value and Engine.is_editor_hint():
		var code := get_level_code()
		DisplayServer.clipboard_set(code)
		print("Level code copied to clipboard (%d chars)" % code.length())
		print(code)
	_export_level_code_to_clipboard = false


func _get_export_level_code_to_level_script() -> bool:
	return _export_level_code_to_level_script


func _set_export_level_code_to_level_script(value: bool) -> void:
	if value and Engine.is_editor_hint():
		_export_level_code_to_level_gd()
	_export_level_code_to_level_script = false


func _get_export_level_code_to_tmp_preview() -> bool:
	return _export_level_code_to_tmp_preview


func _set_export_level_code_to_tmp_preview(value: bool) -> void:
	if value and Engine.is_editor_hint():
		_save_level_code_to_tmp_preview()
	_export_level_code_to_tmp_preview = false


# ---------------------------------------------------------------------------
# Internal: level construction
# ---------------------------------------------------------------------------

func _build_level_from_code(level_code: String) -> void:
	var parsed := LevelCodeParser.parse(level_code)
	for instruction in parsed["instructions"]:
		_set_multiple_cells(instruction["symbols"], instruction["count"], instruction["offset"])

	_level_width_cell = parsed["level_width_cell"]
	_level_height_cell = parsed["level_height_cell"]

	_fill_rectangle_with_walls(_level_width_cell, _level_height_cell)

	var cell_size := Vector2i(terrain_layer.rendering_quadrant_size, terrain_layer.rendering_quadrant_size)
	level_size = Vector2i(_level_width_cell, _level_height_cell) * cell_size
	level_size_updated.emit(level_size)

	_compute_flow_field()


func _fill_rectangle_with_walls(width: int, height: int) -> void:
	var wall_info := _registry.get_info(_WALL_SYMBOL)
	for y in range(height):
		for x in range(width):
			var cell_coords := Vector2i(x, y)
			if terrain_layer.get_cell_tile_data(cell_coords) != null:
				break
			terrain_layer.set_cell(cell_coords, wall_info.source_id, wall_info.atlas_coords)

		for x in range(width - 1, 0, -1):
			var cell_coords := Vector2i(x, y)
			if terrain_layer.get_cell_tile_data(cell_coords) != null:
				break
			terrain_layer.set_cell(cell_coords, wall_info.source_id, wall_info.atlas_coords)


func _set_multiple_cells(cell_symbols: String, cell_cnt: int, offset_coords: Vector2i) -> void:
	if cell_symbols == _EMPTY_SYMBOL:
		return

	var wall_info := _registry.get_info(_WALL_SYMBOL)

	for symbol in cell_symbols:
		var info := _registry.get_info(symbol)
		var cell_layer := _layer_for_type(info.type)

		for i in range(cell_cnt):
			var cell_coords := offset_coords + Vector2i(i, 0)
			cell_layer.set_cell(cell_coords, info.source_id, info.atlas_coords)
			if info.over_wall:
				terrain_layer.set_cell(cell_coords, wall_info.source_id, wall_info.atlas_coords)


func _layer_for_type(type: _TileRegistry.TileType) -> TileMapLayer:
	match type:
		_TileRegistry.TileType.TERRAIN:
			return terrain_layer
		_TileRegistry.TileType.STATIC:
			return static_layer
		_TileRegistry.TileType.OBJECT:
			return objects_layer
		_TileRegistry.TileType.SECRETS:
			return secrets_layer
	return terrain_layer


# ---------------------------------------------------------------------------
# Internal: atlas symbol mapping
# ---------------------------------------------------------------------------

func _init_atlas_symbol_mapping() -> void:
	_static_atlas_coords_to_symbol = {}
	_object_atlas_coords_to_symbol = {}

	for symbol in _registry.get_symbols():
		var info := _registry.get_info(symbol)
		var atlas_coords := str(info.atlas_coords)
		if info.type == _TileRegistry.TileType.STATIC:
			_static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif info.type == _TileRegistry.TileType.OBJECT:
			_object_atlas_coords_to_symbol[atlas_coords] = symbol


func _get_cell_atlas_symbol(cell_coords: Vector2i, type: _TileRegistry.TileType) -> String:
	if type == _TileRegistry.TileType.TERRAIN:
		return _WALL_SYMBOL
	elif type == _TileRegistry.TileType.STATIC:
		var atlas_coords := static_layer.get_cell_atlas_coords(cell_coords)
		return _static_atlas_coords_to_symbol.get(str(atlas_coords), _EMPTY_SYMBOL)
	elif type == _TileRegistry.TileType.OBJECT:
		var atlas_coords := objects_layer.get_cell_atlas_coords(cell_coords)
		return _object_atlas_coords_to_symbol.get(str(atlas_coords), _EMPTY_SYMBOL)
	elif type == _TileRegistry.TileType.SECRETS:
		return _SECRET_SYMBOL
	return _EMPTY_SYMBOL


func _update_static_alt_tiles() -> void:
	for cell_coords in static_layer.get_used_cells():
		var symbol := _get_cell_atlas_symbol(cell_coords, _TileRegistry.TileType.STATIC)
		var alt_tile := _get_alt_tile_at_coords(cell_coords, symbol)
		if alt_tile >= 0:
			var info := _registry.get_info(symbol)
			static_layer.set_cell(cell_coords, info.source_id, info.atlas_coords, alt_tile)
		_add_to_populated_cells(cell_coords, symbol)


# ---------------------------------------------------------------------------
# Internal: object population
# ---------------------------------------------------------------------------

func _populate_objects() -> void:
	for cell_coords in objects_layer.get_used_cells():
		var symbol := _get_cell_atlas_symbol(cell_coords, _TileRegistry.TileType.OBJECT)
		var info := _registry.get_info(symbol)

		var object_position := objects_layer.to_global(objects_layer.map_to_local(cell_coords))
		_add_to_populated_cells(cell_coords, symbol)
		objects_layer.erase_cell(cell_coords)

		if info.scene == null:
			continue

		if symbol == _PLAYER_SYMBOL:
			player_start_position = object_position
			continue

		if symbol == _EXIT_SYMBOL:
			exit_global_position = object_position

		var object := info.scene.instantiate()
		var args := info.args.duplicate()

		var alt_tile := _get_alt_tile_at_coords(cell_coords, symbol)
		if alt_tile >= 0:
			args.append(alt_tile)

		if not args.is_empty():
			object.init(args)

		object.global_position = object_position
		objects_layer.call_deferred("add_child", object)

		if symbol not in objects_map:
			objects_map[symbol] = []
		objects_map[symbol].append(object)


func _init_hidden_areas() -> void:
	for cell_coords in secrets_layer.get_used_cells():
		_add_to_populated_cells(cell_coords, _SECRET_SYMBOL)
	secrets_layer._init_secrets()


# ---------------------------------------------------------------------------
# Internal: decoration spawning
# ---------------------------------------------------------------------------

func _spawn_decoration_grass() -> void:
	if not decorations_layer or not terrain_layer:
		return
	if grass_density <= 0.0:
		return

	var half_tile := Vector2(0, -8)
	var surface_cells := _collect_surface_cells()
	var visited: Dictionary = {}

	for cell_coords: Vector2i in surface_cells.keys():
		if visited.has(cell_coords):
			continue

		var run: Array[Vector2i] = _expand_horizontal_run(cell_coords, surface_cells, visited)
		var run_probability: float = grass_density * clamp((run.size() - 1.0) / 9.0, 0.0, 1.0)
		if run_probability <= 0.0:
			continue

		for run_cell: Vector2i in run:
			if randf() > run_probability:
				continue

			var grass: Node2D = _GRASS_SCENE.instantiate()
			grass.global_position = terrain_layer.to_global(terrain_layer.map_to_local(run_cell) + half_tile)
			decorations_layer.add_child(grass)


func _collect_surface_cells() -> Dictionary:
	var result := {}
	for cell_coords: Vector2i in populated_cells.keys():
		if cell_coords.y == 0:
			continue
		if not _WALL_SYMBOL in populated_cells[cell_coords]:
			continue

		var above := cell_coords + Vector2i.UP
		if populated_cells.has(above):
			continue

		var left := cell_coords + Vector2i.LEFT
		var right := cell_coords + Vector2i.RIGHT
		if not _has_wall_at(left) or not _has_wall_at(right):
			continue

		result[cell_coords] = true
	return result


func _expand_horizontal_run(start: Vector2i, surface_cells: Dictionary, visited: Dictionary) -> Array[Vector2i]:
	var run: Array[Vector2i] = []
	var x := start.x
	var y := start.y

	while surface_cells.has(Vector2i(x, y)):
		x -= 1
	x += 1

	while surface_cells.has(Vector2i(x, y)):
		var cell := Vector2i(x, y)
		run.append(cell)
		visited[cell] = true
		x += 1

	return run


func _has_wall_at(cell_coords: Vector2i) -> bool:
	return populated_cells.has(cell_coords) and _WALL_SYMBOL in populated_cells[cell_coords]


# ---------------------------------------------------------------------------
# Internal: alt tile helpers
# ---------------------------------------------------------------------------

func _get_alt_tile_at_coords(cell: Vector2i, symbol: String) -> int:
	var info := _registry.get_info(symbol)
	if info.alt_tile_callable.is_empty():
		return -1
	return Callable(self, info.alt_tile_callable).call(cell)


func _get_4sides_alt_tile(cell: Vector2i) -> int:
	return _get_alt_tile(cell, [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT])


func _replace_with_alt_tile(_cell: Vector2i) -> int:
	return 1


func _get_alt_tile(cell: Vector2i, directions: Array[Vector2i]) -> int:
	for i in range(directions.size()):
		if terrain_layer.get_cell_tile_data(cell + directions[i]) != null:
			return i
	return 0


# ---------------------------------------------------------------------------
# Internal: terrain visuals
# ---------------------------------------------------------------------------

func _init_terrain_layer() -> void:
	if not terrain_layer or not terrain_visual_layer:
		return

	var used_cells := terrain_layer.get_used_cells()
	if _terrain_layer_used_cells == used_cells:
		return

	terrain_layer.clear_visual_tiles()
	for cell_coords in used_cells:
		terrain_layer.update_visual_tile(cell_coords)
		_add_to_populated_cells(cell_coords, _WALL_SYMBOL)

	_terrain_layer_used_cells = used_cells
	var outline: Array[Vector2] = terrain_layer.get_visual_outline()
	level_outline_updated.emit(outline)


# ---------------------------------------------------------------------------
# Internal: flow field
# ---------------------------------------------------------------------------

func _is_cell_in_bounds(cell_coords: Vector2i) -> bool:
	return (
		cell_coords.x >= 0 and cell_coords.x < _level_width_cell
		and cell_coords.y >= 0 and cell_coords.y < _level_height_cell
	)


func _compute_flow_field() -> void:
	_flow_field = []
	if _level_width_cell == 0 or _level_height_cell == 0:
		return

	for x in range(_level_width_cell):
		var column := []
		column.resize(_level_height_cell)
		column.fill(INF)
		_flow_field.append(column)

	var exit_cell := get_exit_cell_coords()
	if not _is_cell_in_bounds(exit_cell):
		push_warning("Cannot compute flow field: exit cell is outside bounds")
		return

	var costs := get_level_costs()
	var open_set: Array[Vector2i] = [exit_cell]
	_flow_field[exit_cell.x][exit_cell.y] = 0.0

	var directions := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]

	while not open_set.is_empty():
		var best_index := 0
		var best_dist: float = _flow_field[open_set[0].x][open_set[0].y]
		for i in range(1, open_set.size()):
			var d: float = _flow_field[open_set[i].x][open_set[i].y]
			if d < best_dist:
				best_dist = d
				best_index = i

		var current: Vector2i = open_set[best_index]
		open_set.remove_at(best_index)

		for direction in directions:
			var neighbour: Vector2i = current + direction
			if not _is_cell_in_bounds(neighbour):
				continue

			var move_cost: float = costs[neighbour.x][neighbour.y]
			if move_cost == INF:
				continue

			var tentative: float = _flow_field[current.x][current.y] + move_cost
			if tentative < _flow_field[neighbour.x][neighbour.y]:
				_flow_field[neighbour.x][neighbour.y] = tentative
				open_set.append(neighbour)


# ---------------------------------------------------------------------------
# Internal: helpers
# ---------------------------------------------------------------------------

func _add_to_populated_cells(cell_coords: Vector2i, symbol: String) -> void:
	if not populated_cells.has(cell_coords):
		populated_cells[cell_coords] = ""
	populated_cells[cell_coords] += symbol


func _compute_used_bounds() -> Rect2i:
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	var layers: Array[TileMapLayer] = [terrain_layer, static_layer, objects_layer, secrets_layer]

	for layer in layers:
		if not layer:
			continue
		var rect := layer.get_used_rect()
		min_x = min(rect.position.x, min_x)
		min_y = min(rect.position.y, min_y)
		max_x = max(rect.end.x, max_x)
		max_y = max(rect.end.y, max_y)

	if max_x == -INF:
		return Rect2i()

	return Rect2i(min_x, min_y, max_x - min_x, max_y - min_y)
