# Editor Map Editing / Level-Code Export Migration Notes

This document describes the changes made to `src/scenes/level/level.gd` to enable editing the level directly in the Godot editor and exporting the edited layout back to a level-code string.

Use this as a checklist when applying the same behavior to a refactored or divergent branch.

---

## 1. Goal

Allow a designer to:

1. Open `level.tscn` in the Godot editor.
2. Paint/edit tiles on the `TerrainLayer`, `StaticLayer`, `ObjectsLayer`, and `SecretsLayer` TileMap layers.
3. Press an inspector button to generate the level code.
4. Copy it to the clipboard **or** overwrite the `update_level("...")` string inside `src/scenes/level/level.gd`.

---

## 2. High-level behavior changes

### Editor vs. runtime split

| Context | Behavior |
|---|---|
| **Editor (`Engine.is_editor_hint() == true`)** | Keep hand-painted tiles. Do **not** spawn object scenes (player, portal, powerups, etc.). Do **not** erase object/secret tiles. Only rebuild the internal cell map and refresh visual tiles. |
| **Runtime / game** | Keep existing behavior: load from code, instantiate objects, build hidden areas, update static alt tiles, etc. |

### Remove async dependency

Old code used `await self.ready` inside `_get_cell_atlas_symbol()` to wait for initialization. This caused timing errors in the editor because cells were read before the node was ready.

New code reads atlas coordinates synchronously and returns a safe default (`EMPTY_SYMBOL`) if the mapping is missing.

---

## 3. New functions to add

### `force_rebuild_populated_cells()`

Scans the actual TileMap layers and rebuilds `populated_cells` from scratch.

```gdscript
func force_rebuild_populated_cells() -> void:
	populated_cells = {}
	if not terrain_layer:
		return

	_init_atlas_symbol_mapping()

	for cell in terrain_layer.get_used_cells():
		_add_to_populated_cells(cell, WALL_SYMBOL)

	if static_layer:
		for cell in static_layer.get_used_cells():
			var symbol = _get_cell_atlas_symbol(cell, CELL.STATIC)
			if symbol != EMPTY_SYMBOL:
				_add_to_populated_cells(cell, symbol)

	if objects_layer:
		for cell in objects_layer.get_used_cells():
			var symbol = _get_cell_atlas_symbol(cell, CELL.OBJECT)
			if symbol != EMPTY_SYMBOL:
				_add_to_populated_cells(cell, symbol)

	if secrets_layer:
		for cell in secrets_layer.get_used_cells():
			_add_to_populated_cells(cell, SECRET_SYMBOL)
```

### `_export_level_code_to_level_gd()`

Generates the level code and replaces the argument of the first `update_level("...")` call found in `src/scenes/level/level.gd`.

```gdscript
const LEVEL_GD_PATH := "res://src/scenes/level/level.gd"

func _export_level_code_to_level_gd() -> void:
	var level_code: String = get_level_code()
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
```

---

## 4. Functions to modify

### `_ready()`

After initialization, branch on `Engine.is_editor_hint()`:

```gdscript
func _ready() -> void:
	for info in symbol_to_tile_info.values():
		tile_names.append(info["name"])

	_init_atlas_symbol_mapping()
	is_initialized = true

	if Engine.is_editor_hint():
		_init_terrain_layer()
		force_rebuild_populated_cells()
		return

	# runtime path: keep existing calls
	#update_level("<old hardcoded string>")
	_init_terrain_layer()
	_update_static_alt_tiles()
	_populate_objects()
	_init_hidden_areas()
	print(get_level_code())
```

### `update_level(level_code: String)`

Do not spawn objects or build hidden areas in the editor; keep the tiles editable.

```gdscript
func update_level(level_code: String) -> void:
	if len(level_code) == 0 or current_level_code == level_code:
		return

	clear_level()
	set_level(level_code)
	_init_terrain_layer()

	if Engine.is_editor_hint():
		force_rebuild_populated_cells()
		current_level_code = level_code
		return

	_populate_objects()
	_init_hidden_areas()
	_update_static_alt_tiles()
	current_level_code = level_code
```

### `get_level_code() -> String`

Give the function an explicit `String` return type. In the editor (or whenever `populated_cells` is empty), rebuild from the TileMap layers before encoding. Otherwise keep the runtime-populated state.

```gdscript
func get_level_code() -> String:
	if not terrain_layer:
		return ""

	if Engine.is_editor_hint() or populated_cells.is_empty():
		force_rebuild_populated_cells()

	# existing RLE encoding logic...
```

Also fix the bounding-box loop to read each layer's own `get_used_rect()` instead of always reading `terrain_layer.get_used_rect()`.

### `clear_level()`

Do not delete spawned objects in the editor (there are none), and clear `populated_cells`.

```gdscript
func clear_level() -> void:
	for layer: TileMapLayer in [terrain_layer, static_layer, objects_layer, secrets_layer, terrain_visual_layer, secrets_visual_layer]:
		if layer:
			layer.clear()

	if not Engine.is_editor_hint() and objects_layer:
		for child in objects_layer.get_children():
			objects_layer.remove_child(child)
			child.queue_free()

	objects_map = {}
	populated_cells = {}
```

### `_get_cell_atlas_symbol(...)` — remove `await`

Read synchronously and return a default if the mapping is missing.

```gdscript
func _get_cell_atlas_symbol(cell_coords: Vector2i, cell_type: CELL) -> String:
	if cell_type == CELL.TERRAIN:
		return WALL_SYMBOL
	elif cell_type == CELL.STATIC:
		var atlas_coords = static_layer.get_cell_atlas_coords(cell_coords)
		return static_atlas_coords_to_symbol.get(str(atlas_coords), EMPTY_SYMBOL)
	elif cell_type == CELL.OBJECT:
		var atlas_coords = objects_layer.get_cell_atlas_coords(cell_coords)
		return object_atlas_coords_to_symbol.get(str(atlas_coords), EMPTY_SYMBOL)
	elif cell_type == CELL.SECRETS:
		return SECRET_SYMBOL
	return EMPTY_SYMBOL
```

Consequently, remove `await` from `_update_static_alt_tiles()` and `_populate_objects()` when calling `_get_cell_atlas_symbol(...)`.

### `_init_atlas_symbol_mapping()`

Reset the dictionaries before filling them so repeated calls are safe.

```gdscript
func _init_atlas_symbol_mapping() -> void:
	static_atlas_coords_to_symbol = {}
	object_atlas_coords_to_symbol = {}
	for symbol in symbol_to_tile_info:
		var atlas_coords = str(symbol_to_tile_info[symbol]["coords"])
		var cell_type = symbol_to_tile_info[symbol]["type"]
		if cell_type == CELL.STATIC:
			static_atlas_coords_to_symbol[atlas_coords] = symbol
		elif cell_type == CELL.OBJECT:
			object_atlas_coords_to_symbol[atlas_coords] = symbol
```

### `_init_terrain_layer()`

Guard against null layers so it can run safely in the editor before everything is fully wired.

```gdscript
func _init_terrain_layer() -> void:
	if not terrain_layer or not terrain_visual_layer:
		return
	# ... existing logic
```

---

## 5. New inspector properties

Add three `@export` bools at the top of the script. They act as one-shot buttons (the setter resets the value to `false` after executing).

Use backed variables to avoid setter-recursion issues in the inspector.

```gdscript
@export var refresh_editor_preview: bool = false:
	get = _get_refresh_editor_preview,
	set = _set_refresh_editor_preview

@export var export_level_code_to_clipboard: bool = false:
	get = _get_export_level_code_to_clipboard,
	set = _set_export_level_code_to_clipboard

@export var export_level_code_to_level_script: bool = false:
	get = _get_export_level_code_to_level_script,
	set = _set_export_level_code_to_level_script

var _refresh_editor_preview: bool = false
var _export_level_code_to_clipboard: bool = false
var _export_level_code_to_level_script: bool = false


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
		var code: String = get_level_code()
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
```

---

## 6. What to watch when rebasing / refactoring

- If the level script was renamed or split, update `LEVEL_GD_PATH`.
- If the TileMap layer node paths/names changed, make sure the exported `TileMapLayer` references still exist.
- If `update_level("...")` no longer exists in `level.gd`, the regex export will fail; either keep a commented placeholder or change the regex.
- If object instantiation moved out of `Level`, the editor guard (`if Engine.is_editor_hint()`) must be placed wherever tiles would otherwise be erased/replaced by spawned scenes.

---

## 7. Testing after migration

1. Open `level.tscn`.
2. Paint a wall/object/secret.
3. Click **Refresh Editor Preview** → no errors, visual tiles update.
4. Click **Export Level Code to Clipboard** → the generated string appears in the Output panel and is on the clipboard.
5. Click **Export Level Code to Level Script** → `src/scenes/level/level.gd` is modified and the `update_level("...")` argument matches the edited layout.