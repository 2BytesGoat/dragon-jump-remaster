extends Node2D

enum CELL {TERRAIN, STATIC, OBJECT}

# TODO: make a datatype for these
const symbol_to_tile_info: Dictionary = {
	"W": { # wall
		"type": CELL.TERRAIN,
		"autotile": true,
		"source": 0,
		"coords": null,
		"callable": null,
		"debug_alt": null,
		"scene": null
	},
	"V": { # disolve wall
		"type": CELL.OBJECT,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 2),
		"callable": null,
		"debug_alt": null,
		"scene": preload("res://src/secenes/level/tiles/disolve_block.tscn")
	},
	"X": { # spikes
		"type": CELL.STATIC,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(0, 1),
		"callable": "_get_4sides_alt_tile",
		"debug_alt": null,
		"scene": null
	},
	"q": { # blending wall
		"type": CELL.STATIC,
		"autotile": false,
		"source": 0,
		"coords": Vector2i(2, 0),
		"callable": null,
		"debug_alt": null,
		"scene": null
	}
}
# These get populated at runtime
var static_atlas_coords_to_symbol: Dictionary = {}
var object_atlas_coords_to_symbol: Dictionary = {}

@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var static_layer : TileMapLayer = $StaticLayer
@onready var objects_layer: TileMapLayer = $ObjectsLayer


func _ready() -> void:
	_init_atlas_symbol_mapping()
	_update_static_alt_tiles()
	_populate_objects()


func _init_atlas_symbol_mapping() -> void:
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol


func _update_static_alt_tiles() -> void:
	for cell_coords in static_layer.get_used_cells():
		var symbol = _get_cell_symbol(cell_coords, CELL.STATIC)
		var alt_tile_callable = symbol_to_tile_info[symbol]["callable"]
		if alt_tile_callable:
			var tile_source = symbol_to_tile_info[symbol]["source"]
			var tile_coords = symbol_to_tile_info[symbol]["coords"]
			var callable = Callable(self, alt_tile_callable)
			var alt_tile = callable.call(cell_coords)
			static_layer.set_cell(cell_coords, tile_source, tile_coords, alt_tile)


func _populate_objects() -> void:
	for cell_coords in objects_layer.get_used_cells():
		var symbol = _get_cell_symbol(cell_coords, CELL.OBJECT)
		var object_scene = symbol_to_tile_info[symbol]["scene"]
		var object = object_scene.instantiate()
		var object_position = objects_layer.to_global(objects_layer.map_to_local(cell_coords))
		
		object.global_position = object_position
		objects_layer.call_deferred("add_child", object)
		objects_layer.erase_cell(cell_coords)


func _get_cell_symbol(cell_coords: Vector2i, cell_type: CELL) -> String:
	if cell_type == CELL.TERRAIN:
		return "W"
	elif cell_type == CELL.STATIC:
		var atlas_coords = static_layer.get_cell_atlas_coords(cell_coords)
		return static_atlas_coords_to_symbol[str(atlas_coords)]
	elif cell_type == CELL.OBJECT:
		var atlas_coords = objects_layer.get_cell_atlas_coords(cell_coords)
		return object_atlas_coords_to_symbol[str(atlas_coords)]
	return "E"


func _get_4sides_alt_tile(cell: Vector2i) -> int:
	return _get_alt_tile(cell, [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT])


func _get_alt_tile(cell: Vector2i, directions: Array[Vector2i]) -> int:
	for i in range(directions.size()):
		if terrain_layer.get_cell_tile_data(cell + directions[i]) != null:
			return i
	return 0
