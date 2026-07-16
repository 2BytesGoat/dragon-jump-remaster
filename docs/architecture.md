---
title: Dragon Jump Remaster Architecture Documentation
tags: [godot, game-engine, architecture, system-design]
related:
  - "[[main_system]]"
  - "[[player_system]]"
  - "[[level_system]]"
  - "[[save_system]]"
search_terms: [modular-architecture, symbol-based-levels, scene-organization, signal-communication, decoupled-systems]
---

**Overview**: This document outlines the modular architecture of Dragon Jump Remaster, featuring symbol-based level design, scene-based organization, and decoupled game systems with clear communication protocols.

# Dragon Jump Remaster Architecture Documentation

## Project Overview
Dragon Jump Remaster is a 2D platformer game built with Godot Engine. The project uses a modular architecture with scene-based organization and a symbol-driven level layout system. The core gameplay revolves around level navigation with power-ups and collectibles.

## Core Components

### Main Game Loop (`main.gd`)
- **Initialization**: Sets up level, player, camera, and UI components
- **Level Management**: Uses `Level` class to handle level loading and transitions
- **Player Management**: Initializes player instances and handles restarts/finishes
- **Key Signals**:
  - `game_paused` - For UI state management
  - `player_restarted_run`/`player_finished_run` - For game progression tracking

### Level System (`level.gd`)
- **Symbol-Based Layout**: Levels are defined by text codes (e.g., `W42|W8E29W5`)
  - `W` = Wall, `E` = Empty, `P` = Player start, `Q` = Exit
  - Special symbols: `J`=Double Jump, `S`=Stomp, `B`=Bounce Pad, `M`=Secret
- **Tile Mapping System**:
  ```gdscript
  var symbol_to_tile_info: Dictionary = {
      "W": { "name": "Wall", "type": CELL.TERRAIN, ... },
      "P": { "name": "Player", "type": CELL.OBJECT, "scene": preload("res://src/scenes/player/player.tscn"), ... },
      "Q": { "name": "Exit", "type": CELL.OBJECT, "scene": preload("res://src/scenes/level/tiles/portal.tscn"), ... }
  }
  ```
- **Runtime Flow**:
  1. Parse level code into grid structure
  2. Populate tile layers (terrain, static, objects, secrets)
  3. Initialize objects (players, exits, power-ups)
  4. Update visual layers and flow fields

### Autoloaded Singletons
From `project.godot`:

| Singleton | Purpose | Key Functions |
|-----------|---------|---------------|
| `Constants` | Level data and configurations | `Constants.LEVELS` |
| `SignalBus` | Central event system | `player_finished_run`, `new_run_attempt` |
| `SceneManger` | Scene transitions | `go_to(level_scene_path)` |
| `SaveManager` | Game state persistence | `save_game()`, `load_game()` |
| `Utils` | Utility functions | `calculate_distance()`, `clamp_value()` |
| `LeaderboardManager` | High score tracking | `submit_time()`, `get_top_scores()` |

## Asset Organization

### Assets Directory Structure
```
assets/
├── fonts/          # Font resources
├── logos/          # Game logo assets
├── music/          # Background music
├── sfx/            # Sound effects
├── shaders/        # Custom shaders
└── sprites/        # Sprite sheets and individual sprites
```

### Key Scene Assets
- **Player**:
  - `src/scenes/player/player.tscn`
  - Contains player character and physics
- **Level Tiles**:
  - `src/scenes/level/tiles/portal.tscn` (exit)
  - `src/scenes/level/tiles/bounce_pad.tscn`
  - `src/scenes/level/tiles/crown.tscn` (collectible)
- **UI Elements**:
  - `src/ui/menus/level_select.tscn` (level selection menu)

## Level Representation System

### Level Code Format
- **Syntax**: `symbol` + count, separated by `|` for new lines
- **Example**: `W42|W8E29W5` means:
  - 42 Wall tiles, then new line
  - 8 Wall tiles, 29 Empty tiles, 5 Wall tiles
- **Dynamic Behavior**:
  - `callable` properties define runtime behavior (e.g., `_get_4sides_alt_tile`)
  - `over_wall` flag determines if tiles should be drawn over walls

### Key Level Features
1. **Dynamic Tile Behavior**: 
   - Bounce pads (`B`) use `_get_4sides_alt_tile`
   - Reset blocks (`R`) use `_replace_with_alt_tile`
2. **Secret Areas**:
   - `M` symbol marks secret areas
   - Requires special detection logic
3. **Power-ups**:
   - `J` = Double Jump
   - `S` = Stomp
   - `D` = Dash
   - `G` = Grapple

## Architecture Highlights

1. **Symbol-Driven Level Design**: 
   - Allows level designers to create levels using text codes
   - Simplifies level editing and version control

2. **Decoupled Systems**:
   - Level system communicates via signals rather than direct references
   - Singletons provide global access without tight coupling

3. **Modular Scene Structure**:
   - Each game element (player, camera, UI) has its own scene
   - Enables easy replacement and iteration

4. **Extensible Tile System**:
   - New tile types can be added by updating `symbol_to_tile_info`
   - Supports dynamic behavior through `callable` properties

This architecture provides a solid foundation for level design and game progression while maintaining a clean separation of concerns between game systems.