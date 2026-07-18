---
title: Level System Documentation
tags: [godot, game-engine, level-system, tilemap, symbol-based-levels]
related:
  - "[[main_system]]"
  - "[[player_system]]"
  - "[[save_system]]"
search_terms: [level-generation, tilemap-system, symbol-based-levels, terrain-rendering, object-placement, pathfinding]
---

# Level System Documentation

This document outlines the architecture and functionality of the Level system in the Dragon Jump Remaster project.

## Overview

The Level system is responsible for managing game levels, including level generation from code representations, terrain rendering, object placement, and level data handling. It uses a tile-based approach with different layers for terrain, static objects, interactive objects, and secrets.

## Script Components (`*.gd`)

### Key Properties and Their Purposes

| Property | Type | Purpose |
|----------|------|---------|
| `symbol_to_tile_info` | Dictionary | Maps level symbols to tile information including type, coordinates, scene, and callable functions |
| `tile_names` | Array | List of all tile names used in the level |
| `flow_field` | Array | Flow field data for pathfinding |
| `static_atlas_coords_to_symbol` | Dictionary | Maps static atlas coordinates to symbol characters |
| `object_atlas_coords_to_symbol` | Dictionary | Maps object atlas coordinates to symbol characters |
| `terrain_layer` | TileMapLayer | Main terrain layer for the level |
| `static_layer` | TileMapLayer | Static objects layer (walls, spikes, etc.) |
| `objects_layer` | TileMapLayer | Interactive objects layer (power-ups, exits, etc.) |
| `secrets_layer` | TileMapLayer | Secret areas layer |
| `terrain_visual_layer` | TileMapLayer | Visual representation of terrain |
| `secrets_visual_layer` | TileMapLayer | Visual representation of secrets |
| `objects_map` | Dictionary | Maps object types to their instances in the level |
| `player_start_position` | Vector2 | Starting position for the player |
| `populated_cells` | Dictionary | Tracks which cells have been populated with symbols |
| `exit_global_position` | Vector2 | Global position of the exit point |
| `is_initialized` | bool | Flag indicating if the level has been initialized |
| `terrain_layer_used_cells` | Array | Tracks used cells in terrain layer for optimization |
| `elapsed_time` | float | Timer for editor updates (currently named `emplased_time` in code; rename pending) |
| `update_interval` | float | Update interval for editor |
| `current_level_code` | String | Current level code representation |
| `level_width_cell` | int | Width of the level in cells |
| `level_height_cell` | int | Height of the level in cells |
| `level_size` | Vector2 | Size of the level in pixels |

### Main Methods and Their Functionality

| Method | Purpose |
|--------|---------|
| `_enter_tree()` | Handles editor tree entry for processing |
| `_exit_tree()` | Handles editor tree exit for cleanup |
| `_process(delta)` | Processes editor updates at regular intervals |
| `_ready()` | Initializes level system, sets up symbol mappings, and loads level data |
| `update_level(level_code)` | Updates the current level with new code representation |
| `get_level_code()` | Generates level code from current tilemap state |
| `clear_level()` | Clears all cells in all layers and removes child objects |
| `set_level(level_code)` | Parses level code and sets up cells accordingly |
| `get_level_size_cell()` | Returns level size in cells |
| `get_level_costs()` | Returns cost matrix for pathfinding |
| `get_exit_cell_coords()` | Gets cell coordinates of the exit point |
| `reset_objects()` | Resets all objects in the level |
| `get_cell_symbol(cell_coords)` | Gets symbol at specific cell coordinates |
| `get_cell_symbol_index(cell_coords)` | Gets index of cell symbol in symbol list |
| `get_surrounding_cells(global_pos, radius)` | Gets surrounding cells for AI pathfinding |
| `get_tile_names()` | Returns list of all tile names |
| `get_flowfield_value(object_global_position)` | Gets flow field value at position |
| `_is_tilemap_symbol(symbol)` | Checks if symbol is valid for tilemap |
| `_fill_rectangle_with_walls(width, height)` | Fills rectangle with walls |
| `_set_multiple_cells(cell_symbols, cell_cnt, offset_coords)` | Sets multiple cells with given symbols |
| `_init_atlas_symbol_mapping()` | Initializes atlas to symbol mappings |
| `_init_terrain_layer()` | Initializes terrain visual tiles |
| `_update_static_alt_tiles()` | Updates static tiles with alternative tile data |
| `_populate_objects()` | Instantiates and places objects in the level |
| `_init_hidden_areas()` | Initializes secret areas |
| `_get_cell_atlas_symbol(cell_coords, cell_type)` | Gets symbol for cell based on atlas coordinates |
| `_get_4sides_alt_tile(cell)` | Gets alternative tile for 4 surrounding sides |
| `_replace_with_alt_tile(_cell)` | Placeholder for replacement tile logic |
| `_get_alt_tile(cell, directions)` | Gets alternative tile based on surrounding cells |
| `_get_alt_tile_at_coords(cell, symbol)` | Gets alternative tile for specific cell and symbol |
| `_add_to_populated_cells(cell_coords, symbol)` | Adds cell to populated cells dictionary |

### Signals and Connections

| Signal | Emitted When | Purpose |
|--------|--------------|---------|
| `level_size_updated` | When level size changes | Notifies systems of new level dimensions |
| `level_outline_updated` | When level outline changes | Notifies systems of new level boundaries |

### Integration Points with Other Systems

- Connects to `Player` system for player start position and object interactions
- Integrates with `SaveManager` for level data persistence
- Works with `Powerup` system through object placement
- Communicates with `SignalBus` for game events
- Uses `Utils` for various utility functions
- Interfaces with `TileMapLayer` nodes for rendering

## Scene Components (`*.tscn`)

### Scene Hierarchy and Organization

The Level scene is organized as follows:
1. **Level** (Node2D) - Main level container with physics properties
2. **Terrain Layer** (TileMapLayer) - Base terrain tiles layer
3. **Static Layer** (TileMapLayer) - Static objects like walls, spikes
4. **Objects Layer** (TileMapLayer) - Interactive objects like power-ups, exits
5. **Secrets Layer** (TileMapLayer) - Hidden areas and secrets
6. **Terrain Visual Layer** (TileMapLayer) - Visual representation of terrain
7. **Secrets Visual Layer** (TileMapLayer) - Visual representation of secrets

### Key Connections Between Elements

| Connection | Source | Target | Purpose |
|------------|--------|--------|---------|
| `level_size_updated` | Level system | Various systems | Notifies about level size changes |
| `level_outline_updated` | Level system | Various systems | Notifies about level outline changes |

### Visual Layout Considerations

The level scene uses a multi-layered approach:
- **Terrain Layer** - Base ground and background tiles
- **Static Layer** - Walls, spikes, and other static obstacles
- **Objects Layer** - Interactive elements like power-ups, exits, platforms
- **Secrets Layer** - Hidden areas that can be discovered
- **Visual Layers** - Enhanced visual representations for better rendering

## System Integration

### Signal-based Communication Patterns

The Level system communicates through:
1. **Level size and outline updates** - Notifies systems of level changes
2. **Object interactions** - Through collision detection with objects layer
3. **Player start position** - Provides starting point for player character
4. **Exit detection** - Communicates with game flow when player reaches exit

### Data Flow and Control Flow

1. Level data is loaded from code representation in `_ready()`
2. Tilemap layers are populated based on level symbols
3. Objects are instantiated and positioned using `objects_layer`
4. Player start position is set during initialization
5. Level size and outline information is communicated to other systems
6. Secrets and hidden areas are initialized for discovery

## Design Patterns

### Architecture Patterns Used

1. **Factory Pattern** - For creating objects based on symbol mappings in `symbol_to_tile_info`
2. **Layered Architecture** - Separates different types of game elements into distinct layers
3. **Symbol-based Level Definition** - Uses string codes to define levels
4. **Tilemap-based Rendering** - Utilizes Godot's TileMap system for efficient rendering

### Code Organization Principles

- Uses `@tool` annotation for editor-time functionality
- Leverages Godot's built-in signal system for communication
- Implements modular design with clear separation of concerns
- Uses property setters for automatic updates when values change
- Supports editor-time level generation and visualization

### Reusability Considerations

The Level system is designed to be:
- Reusable across different game levels
- Configurable through exported properties
- Extendable with new tile symbols and object types
- Compatible with the existing tilemap architecture
- Support for multiple layer types (terrain, static, objects, secrets)

## Additional Notes

- The level system supports editor-time visualization through `@tool` functionality
- Level codes are encoded using symbol-count pairs for efficient storage
- Multiple tile layers allow for complex level designs with different interaction types
- The system handles alternative tile rendering for dynamic elements like spikes and platforms
- Supports secret areas that can be discovered during gameplay