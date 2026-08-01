# Level Scene Refactor

## Summary

The scripts under `src/scenes/level/` were tightly coupled, relied on loose dictionaries for tile metadata, and mixed editor tooling with runtime logic. This refactor splits responsibilities, introduces typed tile data, and keeps the public API unchanged.

## New file

### `src/scripts/resources/tile_registry.gd`

- New `TileInfo` class with typed fields: `symbol`, `name`, `type`, `source_id`, `atlas_coords`, `scene`, `args`, `over_wall`, `alt_tile_callable`.
- New `TileRegistry` class (`RefCounted`) that owns all tile symbol definitions.
- Replaces the old `SYMBOL_TO_TILE_INFO` dictionary in `level.gd`.
- Breaks the circular dependency between `Level` and `LevelCodeParser`.

## Modified files

### `src/scripts/resources/level_code_parser.gd`

- Now validates symbols through `TileRegistry.default()` instead of reading `Level.SYMBOL_TO_TILE_INFO`.

### `src/scenes/level/level.gd`

- Removed the `CELL` enum and `SYMBOL_TO_TILE_INFO` dictionary.
- Uses `TileRegistry` for all tile metadata lookups.
- Added `_layer_for_type()` helper so layer selection is centralized.
- Reorganized into clear sections: exports, public API, editor export tools, editor triggers, level construction, atlas mapping, object population, alt tiles, terrain visuals, flow field, helpers.
- Kept public API and signals intact:
  - `load_level`, `update_level`, `set_level`, `clear_level`
  - `get_level_code`, `get_level_size_cell`, `get_level_costs`
  - `get_exit_cell_coords`, `get_cell_symbol`, `get_cell_symbol_index`
  - `get_surrounding_cells`, `get_tile_names`, `get_flowfield_value`
  - `reset_objects`
  - `player_start_position`, `exit_global_position`, `populated_cells`, `objects_map`
  - `level_size_updated`, `level_outline_updated`
- Kept `level_size` public so parallax layers can read it before the first signal.
- Preserved the four editor-only export buttons.

### `src/scenes/level/terrain_layer.gd`

- Renamed `update_visual_tiles` to `update_visual_tile` to reflect that it updates one cell and its 2x2 neighbors.
- Renamed `_get_neighbour_count` to `_compute_neighbor_mask` and documented the 2-bit Wang-style neighbor mask.
- Kept the original bit layout so edge/corner tile choices remain unchanged.
- Fixed the autotile array indexing: uses `AUTOTILE_MAP[mask - 1]` so mask `15` maps to the last entry instead of going out of bounds.
- Added explicit type annotations.

### `src/scenes/level/secrets_layer.gd`

- Added clear doc comments.
- Improved type annotations for island detection (`Array[Vector2i]`).
- Extracted readable variable names in `_generate_area_for_island`.
- Replaced manual per-corner polygon math with a `half` vector.
- Converted printed errors to `push_warning`.

### `src/scenes/level/level_background.gd`

- Removed unused `height_scale`, `time_scale`, and dead particle code.
- Kept the `level_outline_updated` signal handler.

### `src/scenes/level/level_wall_blend.gd`

- Renamed local variables for clarity (`local_outline`, `inner`, `outer`, `donut`).
- Added a guard for non-rectangular outlines.
- Simplified `_get_tile_size()`.

### `src/scenes/level/parallax_auto_fit.gd`

- Removed the duplicate `@export var parallax_speed` property.
- The layer now uses the built-in `scroll_scale` directly.
- Updated `_fit` to read `scroll_scale` instead of `parallax_speed`.

### `src/scenes/level/level.tscn`

- Removed the obsolete `parallax_speed` lines from all three `Parallax2D` nodes.
- Existing `scroll_scale` values are unchanged.

## Behavior preservation

- Tile visuals should render identically to the pre-refactor version after the bit-layout fix.
- Level loading, object spawning, secret areas, static alt tiles, flow-field computation, and editor export buttons all follow the same logic as before.
- External callers (player, tests, UI menus, save manager) use the same `Level` public API.

## Verification notes

- Godot `--check-only` passed for all refactored scripts.
- Focused `test_level_load.tscn` passed before stopping the full suite as requested.