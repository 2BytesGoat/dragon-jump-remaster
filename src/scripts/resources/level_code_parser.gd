class_name LevelCodeParser
extends RefCounted

## Parses a level code string (e.g. "W10E5|W3E2Q1...") into a flat list of
## (symbol, count, cell_offset) instructions for a Level to consume.

const EMPTY_SYMBOL := "E"
const SEPARATOR_SYMBOL := "|"

const _TileRegistry := preload("res://src/scripts/resources/tile_registry.gd")


static func parse(level_code: String) -> Dictionary:
	var instructions: Array[Dictionary] = []
	var symbol_cnt = 0
	var current_symbols = ""
	var should_flush = false
	
	var y_offset = 0
	var x_offset = 0
	
	var level_width_cell = 0
	var level_height_cell = 0
	
	for symbol in level_code:
		if _is_tilemap_symbol(symbol):
			if symbol_cnt > 0 and should_flush:
				instructions.append({
					"symbols": current_symbols,
					"count": symbol_cnt,
					"offset": Vector2i(x_offset, y_offset)
				})
				current_symbols = ""
				x_offset += symbol_cnt
				symbol_cnt = 0
				should_flush = false
			current_symbols += symbol
		elif symbol.is_valid_int():
			symbol_cnt = symbol_cnt * 10 + int(symbol)
			should_flush = true
		elif symbol == SEPARATOR_SYMBOL:
			level_width_cell = max(level_width_cell, x_offset + symbol_cnt)
			level_height_cell += 1
			instructions.append({
				"symbols": current_symbols,
				"count": symbol_cnt,
				"offset": Vector2i(x_offset, y_offset)
			})
			current_symbols = ""
			symbol_cnt = 0
			x_offset = 0
			y_offset += 1
	
	if symbol_cnt > 0:
		instructions.append({
			"symbols": current_symbols,
			"count": symbol_cnt,
			"offset": Vector2i(x_offset, y_offset)
		})
		level_width_cell = max(level_width_cell, x_offset + symbol_cnt)
		level_height_cell += 1
	
	return {
		"instructions": instructions,
		"level_width_cell": level_width_cell,
		"level_height_cell": level_height_cell
	}


static func _is_tilemap_symbol(symbol: String) -> bool:
	return _TileRegistry.default().is_valid(symbol)
