@tool
class_name TileRegistry
extends RefCounted

## Central registry of level tile symbols and their metadata.
##
## This replaces the loose SYMBOL_TO_TILE_INFO dictionary in Level.gd with typed
## data so callers get autocomplete, validation, and no circular dependency
## between Level and LevelCodeParser.

enum TileType { TERRAIN, STATIC, OBJECT, SECRETS }

class TileInfo:
	var symbol: String
	var name: String
	var type: TileType
	var source_id: int
	var atlas_coords: Vector2i
	var scene: PackedScene
	var args: Array
	var over_wall: bool
	var alt_tile_callable: StringName

	func _init(
		p_symbol: String,
		p_name: String,
		p_type: TileType,
		p_atlas_coords: Vector2i,
		p_scene: PackedScene = null,
		p_args: Array = [],
		p_over_wall: bool = false,
		p_alt_tile_callable: StringName = &""
	) -> void:
		symbol = p_symbol
		name = p_name
		type = p_type
		source_id = 0
		atlas_coords = p_atlas_coords
		scene = p_scene
		args = p_args
		over_wall = p_over_wall
		alt_tile_callable = p_alt_tile_callable


const EMPTY_SYMBOL := "E"
const WALL_SYMBOL := "W"
const SECRET_SYMBOL := "M"
const SPIKES_SYMBOL := "Y"
const PLAYER_SYMBOL := "P"
const EXIT_SYMBOL := "Q"
const SEPARATOR_SYMBOL := "|"

const _EMPTY_TILE := Vector2i(-1, -1)

var _tiles: Dictionary = {}


func _init() -> void:
	_register_defaults()


func _register_defaults() -> void:
	_register(TileInfo.new(EMPTY_SYMBOL, "Empty", TileType.TERRAIN, _EMPTY_TILE))
	_register(TileInfo.new(WALL_SYMBOL, "Wall", TileType.TERRAIN, Vector2i(0, 0)))
	_register(TileInfo.new(PLAYER_SYMBOL, "Player", TileType.OBJECT, Vector2i(5, 3),
		preload("res://src/scenes/player/player.tscn")))
	_register(TileInfo.new(SPIKES_SYMBOL, "Spikes", TileType.STATIC, Vector2i(0, 2),
		null, [], false, &"_get_4sides_alt_tile"))
	_register(TileInfo.new(EXIT_SYMBOL, "Exit", TileType.OBJECT, Vector2i(6, 3),
		preload("res://src/scenes/level/tiles/portal.tscn")))
	_register(TileInfo.new("R", "ResetBlock", TileType.STATIC, Vector2i(1, 2),
		null, [], false, &"_replace_with_alt_tile"))
	_register(TileInfo.new("B", "BouncePad", TileType.OBJECT, Vector2i(3, 3),
		preload("res://src/scenes/level/tiles/bounce_pad.tscn"), [], false, &"_get_4sides_alt_tile"))
	_register(TileInfo.new("I", "Ice", TileType.OBJECT, Vector2i(1, 3),
		preload("res://src/scenes/level/tiles/slippery_floor.tscn"), [], true))
	_register(TileInfo.new("O", "DissolveBlock", TileType.OBJECT, Vector2i(2, 3),
		preload("res://src/scenes/level/tiles/dissolve_block.tscn")))
	_register(TileInfo.new("J", "DoubleJump", TileType.OBJECT, Vector2i(0, 4),
		preload("res://src/scenes/powerups/powerup.tscn"), ["DoubleJump"]))
	_register(TileInfo.new("S", "Stomp", TileType.OBJECT, Vector2i(1, 4),
		preload("res://src/scenes/powerups/powerup.tscn"), ["Stomp"]))
	_register(TileInfo.new("D", "Dash", TileType.OBJECT, Vector2i(2, 4),
		preload("res://src/scenes/powerups/powerup.tscn"), ["Dash"]))
	_register(TileInfo.new("G", "Grapple", TileType.OBJECT, Vector2i(3, 4),
		preload("res://src/scenes/powerups/powerup.tscn"), ["Grapple"]))
	_register(TileInfo.new("g", "Grass", TileType.OBJECT, Vector2i(0, 5),
		preload("res://src/scenes/level/tiles/grass.tscn"), []))
	_register(TileInfo.new(SECRET_SYMBOL, "Secret", TileType.SECRETS, Vector2i(0, 1), null, [], true))


static func default() -> TileRegistry:
	return TileRegistry.new()


func _register(info: TileInfo) -> void:
	_tiles[info.symbol] = info


func has(symbol: String) -> bool:
	return symbol in _tiles


func get_info(symbol: String) -> TileInfo:
	return _tiles.get(symbol, _tiles.get(EMPTY_SYMBOL))


func get_symbols() -> Array:
	return _tiles.keys()


func get_names() -> Array[String]:
	var result: Array[String] = []
	for info in _tiles.values():
		result.append(info.name)
	return result


func get_symbols_by_type(type: TileType) -> Array:
	var result := []
	for info in _tiles.values():
		if info.type == type:
			result.append(info.symbol)
	return result


func is_empty(symbol: String) -> bool:
	return symbol == EMPTY_SYMBOL


func is_valid(symbol: String) -> bool:
	return is_empty(symbol) or has(symbol)


func get_layer_for_type(type: TileType) -> TileMapLayer:
	# This is a lookup helper used by Level. It cannot return a node itself
	# because TileRegistry is a RefCounted resource with no scene access.
	# Callers pass the result to their own layer mapping.
	return null
