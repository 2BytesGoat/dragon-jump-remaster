@tool
class_name Level
extends Node2D

enum CELL {TERRAIN, STATIC, OBJECT, SECRETS}

const WALL_SYMBOL = "W"
const SECRET_SYMBOL = "M"
const EMPTY_SYMBOL = "E"
const SPIKES_SYMBOL = "Y"
const PLAYER_SYMBOL = "P"
const EXIT_SYMBOL = "Q"
const SEPARATOR_SYMBOL = "|"

# TODO: make a datatype for these
var symbol_to_tile_info: Dictionary = {
	EMPTY_SYMBOL: {
		"name": "Empty",
		"type": CELL.TERRAIN,
		"source": 0,
		"coords": Vector2i(-1, -1),
		"callable": null,
		"debug_alt": null,
		"scene": null,
		"args": null,
		"over_wall": false
	},
	WALL_SYMBOL: { 
		"name": "Wall",
		"type": CELL.TERRAIN,
		"source": 0,
		"coords": Vector2i(0, 0),
		"callable": null,
		"debug_alt": null,
		"scene": null,
		"args": null,
		"over_wall": false
	},
	PLAYER_SYMBOL: {
		"name": "Player",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(5, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/player/player.tscn"),
		"args": null,
		"over_wall": false
	},
	SPIKES_SYMBOL: {
		"name": "Spikes",
		"type": CELL.STATIC,
		"source": 0,
		"coords": Vector2i(0, 2),
		"callable": "_get_4sides_alt_tile",
		"debug_alt": null,
		"scene": null,
		"args": null,
		"over_wall": false
	},
	EXIT_SYMBOL: {
		"name": "Exit",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(6, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/level/tiles/portal.tscn"),
		"args": null,
		"over_wall": false
	},
	"R": {
		"name": "ResetBlock",
		"type": CELL.STATIC,
		"source": 0,
		"coords": Vector2i(1, 2),
		"callable": "_replace_with_alt_tile",
		"debug_alt": null,
		"scene": null,
		"args": null,
		"over_wall": false
	},
	"B": {
		"name": "BouncePad",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(3, 3),
		"callable": "_get_4sides_alt_tile",
		"debug_alt": null,
		"scene": preload("res://src/scenes/level/tiles/bounce_pad.tscn"),
		"args": null, # These sould get set in the callable
		"over_wall": false
	},
	"I": {
		"name": "Ice",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(1, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/level/tiles/slippery_floor.tscn"),
		"args": null,
		"over_wall": true
	},
	"O": {
		"name": "DissolveBlock",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(2, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/level/tiles/dissolve_block.tscn"),
		"args": null,
		"over_wall": false
	},
	"J": {
		"name": "DoubleJump",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(0, 4),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/powerups/powerup.tscn"),
		"args": ["DoubleJump"],
		"over_wall": false
	},
	"S": {
		"name": "Stomp",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(1, 4),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/powerups/powerup.tscn"),
		"args": ["Stomp"],
		"over_wall": false
	},
	"D": {
		"name": "Dash",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(2, 4),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/powerups/powerup.tscn"),
		"args": ["Dash"],
		"over_wall": false
	},
	"G": {
		"name": "Grapple",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(3, 4),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/powerups/powerup.tscn"),
		"args": ["Grapple"],
		"over_wall": false
	},
	"C": {
		"name": "Crown",
		"type": CELL.OBJECT,
		"source": 0,
		"coords": Vector2i(4, 3),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/scenes/level/tiles/crown.tscn"),
		"args": null,
		"over_wall": false
	},
	"M": {
		"name": "Secret",
		"type": CELL.SECRETS,
		"source": 0,
		"coords": Vector2i(0, 1),
		"callable": null,
		"debug_alt": null,
		"scene": null,
		"args": null,
		"over_wall": true
	}
}
var tile_names := []
var flow_field := []

# These get populated at runtime
var static_atlas_coords_to_symbol: Dictionary = {}
var object_atlas_coords_to_symbol: Dictionary = {}

@export var terrain_layer: TileMapLayer
@export var static_layer : TileMapLayer
@export var objects_layer: TileMapLayer
@export var secrets_layer: TileMapLayer
@export var terrain_visual_layer: TileMapLayer
@export var secrets_visual_layer: TileMapLayer

var objects_map: Dictionary = {}
var player_start_position: Vector2 = Vector2.ZERO
var populated_cells: Dictionary = {}

# Progress
var exit_global_position = Vector2.ZERO
var first_time_touching_crown = true

# These are used to debug in editor
var is_initialized = false
var terrain_layer_used_cells = [] # based on this we update the map using tool
var emplased_time = 0
var update_interval = 1
var current_level_code = ""
var level_width_cell = 0
var level_height_cell = 0
var level_size = Vector2.ZERO

signal level_size_updated(level_size: Vector2i)


func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_process(true)


func _exit_tree() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint() and is_initialized:
		return
	
	emplased_time += delta
	if emplased_time >= update_interval:
		_init_terrain_layer()
		emplased_time = 0


func _ready() -> void:
	for info in symbol_to_tile_info.values():
		tile_names.append(info["name"])
	
	clear_level()
	#var old_code = "W42|W8E29W5|W3E37W2|W2E38W2|W1E25Y2E13W1|W1E25W2Y1E12W1|W1E25W2Y1E12W1|W1E25W2Y1E12W1|W1E15J1E4J1E4W2Y1E11B1W1|W1E30B2E8W1|W9E22W2E8W1|W9Y8E24W1|W17E6Y2E16W1|W17E5Y1W2Y1E11B1E1Y2W1|W7E15Y1W2Y1E10W6|W3E20Y2E11W6|W2E34W6|W1E35W6|W1E13J1E4B1E10B2E1Y3W6|W1E18W1E9W13|W1E18W1E9W13|W1E28W13|W1E23W18|W1E23W18|W1E2P1E8B1E11W18|W19Y5W18|W42"
	#var level_code = old_code.replace("q", "E").replace("X", "Y").replace("/", "|").replace("V", "O").replace("D", "J")
	#set_level(level_code)
	#_init_terrain_layer()
	#_populate_objects()
	#_init_hidden_areas()
	#_update_static_alt_tiles()
	#print(get_level_code())
	
	_init_atlas_symbol_mapping()
	#_init_terrain_layer()
	
	if not Engine.is_editor_hint():
		#old_code = "W34E19|W5E13O1E4W3E5W3E19|W4E14O1E4W2E7W2E19|W2E16O1E4W2E8W1E19|W2E16O1E4W2E8W1E19|W2E16O1E4W2E8W1E19|W2E16O1E4W2E8W1E18W1|W2E16O1E14W1E19|W2E31W1E19|W2E49W1E1|E1W15Y5W6E6W1E19|E1W26E6W1E19|E1W2E8W3E4O1E14W1E19|W2E10W2E4O1E14W1E19|W1E11W2E4O1E14W1E19|W1E11W2E4O1E14W1E19|W1E17O1E14W1E19|W1E26W7E19|W1E1P1E5W1E18W7E19|W17Y3W14E19|E16W5E32"
		#level_code = old_code.replace("q", "E").replace("X", "Y").replace("/", "|").replace("V", "O")
		#clear_level()
		#set_level(level_code)
		_init_terrain_layer()
		_update_static_alt_tiles()
		_populate_objects()
		_init_hidden_areas()
		current_level_code = get_level_code()
		#print(get_level_code())

	is_initialized = true


func update_level(level_code: String) -> void:
	if len(level_code) == 0 or current_level_code == level_code:
		return
	
	clear_level()
	set_level(level_code)
	_init_terrain_layer()
	_populate_objects()
	_init_hidden_areas()
	_update_static_alt_tiles()
	current_level_code = level_code


func get_level_code():
	# get min x,y and max x,y
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	var layers = [terrain_layer, static_layer, objects_layer, secrets_layer]
	
	for layer in layers:
		var rect_size = terrain_layer.get_used_rect()
		min_x = min(rect_size.position.x, min_x)
		min_y = min(rect_size.position.y, min_y)
		max_x = max(rect_size.end.x, max_x)
		max_y = max(rect_size.end.y, max_y)
	
	# because we need them to capture all used cells
	level_size = Vector2(abs(max_x - min_x), abs(max_y - min_y))
	var shift = Vector2i(min_x, min_y)
	
	var current_symbol = null
	var current_symbol_cnt = 0
	var level_code = ""
	for y in range(level_size.y):
		for x in range(level_size.x):
			var cell_coords = Vector2i(x, y) + shift
			var cell_symbol = get_cell_symbol(cell_coords)
			
			if cell_symbol != current_symbol:
				if current_symbol_cnt > 0:
					level_code += "%s%s" % [current_symbol, current_symbol_cnt]
				current_symbol = cell_symbol
				current_symbol_cnt = 0
			
			current_symbol_cnt += 1
		
		if current_symbol_cnt > 0:
			level_code += "%s%s" % [current_symbol, current_symbol_cnt]
		
		if y < level_size.y - 1:
			level_code += SEPARATOR_SYMBOL
		
		current_symbol_cnt = 0
	
	return level_code


func clear_level() -> void:
	for layer: TileMapLayer in [terrain_layer, static_layer, objects_layer, secrets_layer, terrain_visual_layer, secrets_visual_layer]:
		layer.clear()
	
	for child in objects_layer.get_children():
		objects_layer.remove_child(child)
		child.queue_free()
	
	objects_map = {}


func set_level(level_code: String) -> void:
	var symbol_cnt = 0
	var current_symbols = ""
	var should_flush = false
	
	var y_offset = 0
	var x_offset = 0
	
	level_width_cell = 0
	level_height_cell = 0
	
	for symbol in level_code:
		if _is_tilemap_symbol(symbol):
			if symbol_cnt > 0 and should_flush:
				_set_multiple_cells(current_symbols, symbol_cnt, Vector2i(x_offset, y_offset))
				current_symbols = ""
				x_offset += symbol_cnt
				symbol_cnt = 0
				should_flush = false
			current_symbols += symbol
		elif symbol.is_valid_int():
			symbol_cnt = symbol_cnt * 10 + int(symbol)
			should_flush = true
		elif symbol == "|":
			level_width_cell = max(x_offset, level_width_cell)
			level_height_cell += 1
			_set_multiple_cells(current_symbols, symbol_cnt, Vector2i(x_offset, y_offset))
			current_symbols = ""
			symbol_cnt = 0
			x_offset = 0
			y_offset += 1
	if symbol_cnt > 0:
		_set_multiple_cells(current_symbols, symbol_cnt, Vector2i(x_offset, y_offset))
		level_height_cell += 1
	
	var cell_size = Vector2i(terrain_layer.rendering_quadrant_size, terrain_layer.rendering_quadrant_size)
	level_size = Vector2i(level_width_cell, level_height_cell) * cell_size
	level_size_updated.emit(level_size)


func get_level_size_cell() -> Vector2i:
	return Vector2i(level_width_cell, level_height_cell)


func get_level_costs() -> Array:
	var costs = []
	for x in range(level_width_cell):
		var row_costs = []
		for y in range(level_height_cell):
			var cell_type = get_cell_symbol(Vector2i(x, y))
			var cell_cost = 1.0
			if cell_type in [WALL_SYMBOL, SPIKES_SYMBOL]:
				cell_cost = INF
			row_costs.append(cell_cost)
		costs.append(row_costs)
	return costs


func get_exit_cell_coords() -> Vector2i:
	return terrain_layer.local_to_map(to_local(exit_global_position))


func reset_objects() -> void:
	for obj_type in objects_map:
		for obj in objects_map[obj_type]:
			if obj.has_method("reset"):
				obj.call_deferred("reset")


func get_cell_symbol(cell_coords: Vector2i) -> String:
	return populated_cells.get(cell_coords, EMPTY_SYMBOL)


func get_cell_symbol_index(cell_coords: Vector2i) -> int:
	var cell_symbol = get_cell_symbol(cell_coords)
	return symbol_to_tile_info.keys().find(cell_symbol)


func get_surrounding_cells(global_pos: Vector2, radius: int) -> Array:
	var center_tile = terrain_layer.local_to_map(to_local(global_pos))
	var grid_data = []
	
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var coords = center_tile + Vector2i(x, y)
			# Normalize cell_type: e.g., Empty = 0, Wall = 1, Spike = 2
			var cell_type = get_cell_symbol_index(coords) 
			grid_data.append(cell_type)
	
	return grid_data


func get_tile_names() -> Array:
	return tile_names


func get_flowfield_value(object_global_position: Vector2) -> float:
	if len(flow_field) == 0:
		print("Undefined Flow Field: Returning default value 0")
		return 0
	var cell_coords = terrain_layer.local_to_map(to_local(object_global_position))
	return flow_field[cell_coords.x][cell_coords.y]


func _is_tilemap_symbol(symbol: String) -> bool:
	return symbol == EMPTY_SYMBOL or symbol in symbol_to_tile_info


func _set_multiple_cells(cell_symbols: String, cell_cnt: int, offset_coords: Vector2i) -> void:
	if cell_symbols == EMPTY_SYMBOL:
		return
	
	for symbol in cell_symbols:
		var wall_info = symbol_to_tile_info[WALL_SYMBOL]
		var cell_type_info = symbol_to_tile_info[symbol]
		var cell_layer = terrain_layer
		match cell_type_info["type"]:
			CELL.TERRAIN:
				cell_layer = terrain_layer
			CELL.STATIC:
				cell_layer = static_layer
			CELL.OBJECT:
				cell_layer = objects_layer
			CELL.SECRETS:
				cell_layer = secrets_layer
		
		#print(cell_layer, ' ', cell_type_info, ' ', cell_cnt)
		for i in range(cell_cnt):
			cell_layer.set_cell(offset_coords + Vector2i(i, 0), cell_type_info["source"], cell_type_info["coords"])
			if cell_type_info["over_wall"]:
				terrain_layer.set_cell(offset_coords + Vector2i(i, 0), wall_info["source"], wall_info["coords"])


func _init_atlas_symbol_mapping() -> void:
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol


func _init_terrain_layer() -> void:
	var used_cells = terrain_layer.get_used_cells()
	if terrain_layer_used_cells == used_cells:
		return
	
	terrain_layer.clear_visual_tiles()
	for cell_coords in used_cells:
		terrain_layer.update_visual_tiles(cell_coords)
		_add_to_populated_cells(cell_coords, WALL_SYMBOL)
	
	terrain_layer_used_cells = used_cells


func _update_static_alt_tiles() -> void:
	for cell_coords in static_layer.get_used_cells():
		var symbol = await _get_cell_atlas_symbol(cell_coords, CELL.STATIC)
		var alt_tile = _get_alt_tile_at_coords(cell_coords, symbol)
		if alt_tile >= 0:
			var tile_source = symbol_to_tile_info[symbol]["source"]
			var tile_coords = symbol_to_tile_info[symbol]["coords"]
			static_layer.set_cell(cell_coords, tile_source, tile_coords, alt_tile)
		_add_to_populated_cells(cell_coords, symbol)


func _populate_objects() -> void:
	for cell_coords in objects_layer.get_used_cells():
		var symbol = await _get_cell_atlas_symbol(cell_coords, CELL.OBJECT)
		var object_scene = symbol_to_tile_info[symbol]["scene"]
		var object_arguments = symbol_to_tile_info[symbol]["args"]
		
		var object_position = objects_layer.to_global(objects_layer.map_to_local(cell_coords))
		_add_to_populated_cells(cell_coords, symbol)
		objects_layer.erase_cell(cell_coords)
		
		if symbol == PLAYER_SYMBOL:
			player_start_position = object_position
			continue
		
		if symbol == EXIT_SYMBOL:
			exit_global_position = object_position
		
		var object = object_scene.instantiate()
		
		var alt_tile = _get_alt_tile_at_coords(cell_coords, symbol)
		if alt_tile >= 0:
			if not object_arguments:
				object_arguments = []
			object_arguments.append(alt_tile)
		
		if object_arguments:
			object.init(object_arguments)
		
		object.global_position = object_position
		objects_layer.call_deferred("add_child", object)
		
		if symbol not in objects_map:
			objects_map[symbol] = []
		objects_map[symbol].append(object)


func _init_hidden_areas() -> void:
	for cell_coords in secrets_layer.get_used_cells():
		_add_to_populated_cells(cell_coords, SECRET_SYMBOL)
	secrets_layer._init_secrets()


func _get_cell_atlas_symbol(cell_coords: Vector2i, cell_type: CELL) -> String:
	if not is_initialized:
		await self.ready
	
	if cell_type == CELL.TERRAIN:
		return WALL_SYMBOL
	elif cell_type == CELL.STATIC:
		var atlas_coords = static_layer.get_cell_atlas_coords(cell_coords)
		return static_atlas_coords_to_symbol[str(atlas_coords)]
	elif cell_type == CELL.OBJECT:
		var atlas_coords = objects_layer.get_cell_atlas_coords(cell_coords)
		return object_atlas_coords_to_symbol[str(atlas_coords)]
	# TODO: add handle for secrets
	return EMPTY_SYMBOL


func _get_4sides_alt_tile(cell: Vector2i) -> int:
	return _get_alt_tile(cell, [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT])


func _replace_with_alt_tile(_cell: Vector2i) -> int:
	return 1


func _get_alt_tile(cell: Vector2i, directions: Array[Vector2i]) -> int:
	for i in range(directions.size()):
		if terrain_layer.get_cell_tile_data(cell + directions[i]) != null:
			return i
	return 0


func _get_alt_tile_at_coords(cell: Vector2i, symbol: String):
	var alt_tile_callable = symbol_to_tile_info[symbol]["callable"]
	if alt_tile_callable:
		var callable = Callable(self, alt_tile_callable)
		return callable.call(cell)
	return -1


func _add_to_populated_cells(cell_coords: Vector2i, symbol: String) -> void:
	if not populated_cells.has(cell_coords):
		populated_cells[cell_coords] = ""
	populated_cells[cell_coords] += symbol
