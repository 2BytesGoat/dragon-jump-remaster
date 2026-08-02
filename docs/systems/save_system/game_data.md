---
title: GameData Resource Documentation
tags: [godot, game-engine, data-resource, player-progress, level-data, save-system]
related:
  - "[[systems/save_system/save_system.md]]"
  - "[[systems/level_system/level_system.md]]"
  - "[[systems/player_system/player_system.md]]"
search_terms: [game-data-resource, player-save, level-progress, data-structure, serialization, deserialization, save-manager, resource-system, game-state]
---

# GameData Resource Documentation

## Overview
- High-level description of the system's purpose: The `GameData` resource in Dragon Jump Remaster represents the top-level data structure for storing player progress and game state. It serves as the primary container for all player-related information including player name and level progress data. This resource is serialized to disk using Godot's resource system to persist game progress between sessions.
- Role within the overall architecture: This resource acts as the main container for player game state, enabling persistent storage of player progress across game sessions.
- Key search terms and concepts for RAG retrieval: game-data-resource, player-save, level-progress, data-structure, serialization, deserialization, save-manager, resource-system, game-state
- System relationships and dependencies: Related to save system (data persistence), level system (level tracking), player system (player identification)

## Script Components (`*.gd`)
### `game_data.gd`
- Key properties and their purposes:
  - `player_name`: String - Name of the player associated with this save data
  - `levels`: Dictionary - Dictionary mapping level names to LevelData objects containing specific level progress information
- Main methods and their functionality:
  - None (this is a resource, not a script node)
- Signals and connections:
  - None (this is a resource, not a script node)
- Integration points with other systems:
  - Used by SaveManager singleton for serialization/deserialization of player progress
  - Connects to level system for per-level progress tracking through the levels dictionary
  - Integrates with player system for player identification via player_name field
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include efficient data structure usage and minimal memory overhead
  - Optimization hints involve using appropriate dictionary structures for level access

## Scene Components (`*.tscn`)
### `game_data.tscn`
- Scene hierarchy and organization:
  - This is a resource file, not a scene
- Key connections between elements:
  - None (this is a resource, not a scene)
- Visual layout considerations:
  - No visual elements required for this system
- RAG metadata: visual design patterns, UI flow
  - Not applicable for resource files

## System Integration
- How the system interacts with other components: The GameData resource integrates with the SaveManager singleton and connects to level and player systems for data persistence and tracking.
- Signal-based communication patterns: Uses signals from SaveManager for save/load events
- Data flow and control flow:
  1. SaveManager initializes new GameData instances
  2. Player progress updates GameData levels dictionary
  3. SaveManager serializes GameData to disk
  4. SaveManager deserializes GameData from disk
- Cross-system relationships for RAG linking: Related to save system (data persistence), level system (level tracking), player system (player identification)

## Design Patterns
- Architecture patterns used:
  - Resource pattern for data persistence
  - Dictionary pattern for scalable level organization
  - Data container pattern for structured information storage
- Code organization principles:
  - Separation of concerns between data structure and behavior
  - Modular design for reusable game state management
- Reusability considerations:
  - Can be reused across different save/load operations
  - Supports multiple player profiles through player_name field
- Pattern-specific RAG tags and categorization:
  - resource-pattern
  - dictionary-pattern
  - data-container-pattern
  - save-system

## Implementation Details
- Key code examples:
  - `var game_data = GameData.new()` - Creating new game data instance
  - `game_data.player_name = "Player1"` - Setting player name
  - `ResourceSaver.save(game_data, "user://save_game.tres")` - Saving game data to disk
  - `var loaded_data = ResourceLoader.load("user://save_game.tres")` - Loading game data from disk
- Important algorithms or logic:
  - Data serialization for save/load operations
  - Dictionary-based level access for efficient progress tracking
  - Player identification and profile management
- Performance considerations:
  - Efficient data structure usage to minimize memory overhead
  - Fast dictionary lookups for level progress access
  - Proper resource handling to avoid memory leaks

## See Also
- [[systems/save_system/save_system.md]]
- [[systems/level_system/level_system.md]]
- [[systems/player_system/player_system.md]]

