---
title: Other Scripts Documentation
tags: [godot, game-engine, utilities, constants, scene-loader, utils]
related:
  - "[[main_system]]"
  - "[[save_system]]"
search_terms: [constants, scene-loader, utils, utility-functions, player-name-validation, time-formatting]
---

# Other Scripts Documentation

## Overview
The Other Scripts system contains utility classes and shared singletons that support the rest of the game. It covers constant/resource references (`constants.gd`), scene transition handling (`scene_loader.gd`), and static helper functions (`utils.gd`). A build-time-only template (`runtime_secrets.gd.template`) is documented at the end.

Key search terms and concepts for RAG retrieval: constants, scene-loader, utils, utility-functions, player-name-validation, time-formatting
System relationships and dependencies: This system integrates with the main system for initialization, the save system for data management, and all other systems that require utility functions or scene navigation.

## Script Components (`*.gd`)

### `constants.gd`
- **Purpose**: Static helper with default values and shared resource references. Tunable data lives in Resource assets under `res://resources/`. **Not an autoload** — access via `Constants` class name.
- **Key properties**:
  - `DEFAULT_PLAYER_NAME`: Default name for unnamed players (`"UNK"`)
  - `PHYSICS_PARAMS`: Preloaded `physics_params.tres`
  - `MEDAL_CONFIG`: Preloaded `medal_config.tres`
  - `POWERUP_PALETTE`: Preloaded `powerup_palette.tres`
  - `AUDIO_BUS_CONFIG`: Preloaded `audio_bus_config.tres`
- **Integration points with other systems**:
  - Used by the save system for default player naming
  - Shared resource references consumed across player, level, and meta systems
- **RAG metadata**: Static class (extends `RefCounted`), no runtime state.

### `scene_loader.gd`
- **Purpose**: Autoload singleton (`SceneLoader`) that owns scene changes with a fade overlay and error reporting.
- **Key properties**:
  - `scene_data`: Dictionary storing data to pass between scenes
  - `FADE_DURATION_SECONDS`: Fade transition length (`0.5`)
- **Main methods**:
  - `go_to(scene_path: String, data: Dictionary = {})`: Navigates to the specified scene, deferring the change until pending input is processed
- **Integration points with other systems**:
  - Used by main system, UI menus, and level flow for all scene navigation
- **RAG metadata**: Owns a `CanvasLayer` overlay; handles fade in/out tweens and reports load errors instead of crashing.

### `utils.gd`
- **Purpose**: Collection of static utility functions used throughout the game. **Not an autoload** — call directly via `Utils.method()`.
- **Main methods**:
  - `get_weighted_array_item(array: Array, weights=[])`: Returns item from array based on weighted probability
  - `instance_scene_on_main(scene, position, rotation=0.0, scale=Vector2.ONE)`: Instantiates a scene onto the active level
  - `format_time(time_sec: float)`: Formats time into `MM:SS.CC`
  - `format_duration(time_sec: float)`: Formats a large duration as `HH:MM:SS`
  - `is_allowed_player_name(player_name: String)`: Validates player name against regex pattern
  - `generate_dijkstra_map(grid_size: Vector2i, costs: Array, target: Vector2i)`: Generates a Dijkstra map for AI pathfinding
- **Integration points with other systems**:
  - Used by player system for movement calculations
  - Integrates with level system for pathfinding
  - Connects to UI components for time formatting and name validation
  - Used by save system for data processing
- **RAG metadata**: Static class (extends `RefCounted`); performance-sensitive pathfinding and formatting helpers.

### `runtime_secrets.gd.template`
- **Purpose**: Build-time template for runtime secrets. Copy it to `runtime_secrets.gd` and fill in real values during the release pipeline.
- **Key properties**:
  - `is_set`: Set to `true` once a real secret has been injected
  - `HMAC_SECRET`: HMAC secret used by `SaveManager` to sign save files
- **Integration points with other systems**:
  - Consumed by `SaveManager._get_hmac_secret()` via `Engine.get_singleton("RuntimeSecrets")` when present
- **RAG metadata**: The committed project does not register this file as an autoload; the build pipeline may add it when injecting real secrets. The `.gd` file is gitignored and must never be committed.

## Scene Components (`*.tscn`)
None - This system consists entirely of scripts.

## System Integration
- How the system interacts with other components: The Other Scripts system provides foundational utilities and shared singletons used throughout the game architecture
- Signal-based communication patterns: No direct signal connections; integrates with systems through function calls
- Data flow and control flow: Utility functions → Game systems → Data processing → Result feedback
- Cross-system relationships for RAG linking: Related to main system (initialization/scene flow), save system (data management), player system (game logic), UI components (display)

## Design Patterns
- Architecture patterns used: Singleton pattern for `SceneLoader`, static helper classes for `Constants` and `Utils`
- Code organization principles: Separation of concerns between data storage, scene navigation, and utility functions
- Reusability considerations: Utility functions can be reused across different game systems
- Pattern-specific RAG tags and categorization: singleton-pattern, utility-functions, configuration-management

## Implementation Details
- Key code examples:
  - `get_tree().change_scene_to_file(scene_path)` - Scene navigation with fade transition
  - `format_time(time_sec: float)` - Time formatting function
  - `generate_dijkstra_map()` - Pathfinding algorithm implementation
  - `Engine.get_singleton("RuntimeSecrets")` - Optional build-injected secrets lookup
- Important algorithms or logic:
  - Weighted random selection for powerup spawning
  - Dijkstra pathfinding algorithm for AI navigation
  - Fade-transition scene loading
  - Time formatting with centisecond precision
- Performance considerations: Efficient data access, proper caching of results, minimal memory usage

## See Also
- [[systems/main_system/main_system.md]]
- [[systems/save_system/save_system.md]]
