---
title: GameData Resource Documentation
tags: [godot, game-engine, data-resource, player-progress, level-data]
related: [[save_system/save_system.md]], [[level_system/level_system.md]], [[player_system/player_system.md]]
search_terms: [game-data-resource, player-save, level-progress, data-structure, serialization, deserialization]
---

# GameData Resource

## Overview

The `GameData` resource in Dragon Jump Remaster represents the top-level data structure for storing player progress and game state. It serves as the primary container for all player-related information including player name and level progress data. This resource is serialized to disk using Godot's resource system to persist game progress between sessions.

## Script Components (`game_data.gd`)

### Key Properties

| Property | Type | Purpose |
|----------|------|---------|
| `player_name` | String | Name of the player associated with this save data |
| `levels` | Dictionary | Dictionary mapping level names to LevelData objects containing specific level progress information |

### Main Functionality

The GameData resource is designed as a container for player game state and does not contain any methods or logic. It serves purely as a data structure that holds the following information:
- Player identification through `player_name` field
- Per-level progress tracking in the `levels` dictionary, where each key is a level name (e.g., "1-1", "1-2") and each value is a LevelData resource object

## System Integration

The GameData resource integrates with the SaveManager singleton through the following mechanisms:
1. **Data Persistence**: Used by SaveManager to serialize/deserialize player progress to/from disk
2. **Level Progress Tracking**: The `levels` dictionary provides access to individual level data for progress tracking and updates
3. **Player Identification**: The `player_name` field enables multi-player support by associating save data with specific players

## Design Patterns

### Resource-based Data Structure
Uses Godot's built-in Resource system as the foundation for data persistence, enabling automatic serialization and deserialization of game state.

### Dictionary-based Organization
Organizes level data using a dictionary structure where keys are level identifiers (strings) and values are LevelData resources, allowing flexible and scalable level progression tracking.

## Data Flow

1. **Initialization**: SaveManager creates new GameData instances with default player name and empty levels dictionary
2. **Progress Tracking**: As players complete levels, SaveManager updates the corresponding LevelData objects within the `levels` dictionary
3. **Persistence**: When saving, SaveManager serializes the entire GameData resource to disk using Godot's ResourceSaver
4. **Loading**: When loading, SaveManager deserializes the GameData resource from disk using Godot's ResourceLoader

## File Structure

### Location
GameData resources are stored in `src/scripts/resources/game_data.gd` and are used by the SaveManager singleton.

### Usage in Save System
The GameData resource is the primary data structure used throughout the save system:
- Created when a new player save is initialized
- Updated as players complete levels
- Serialized to disk using `ResourceSaver.save()` method
- Deserialized from disk using `ResourceLoader.load()` method

## Relationship with LevelData

GameData works in conjunction with LevelData resources through the `levels` dictionary. Each entry in this dictionary corresponds to a LevelData resource that contains specific information about an individual level's progress, including:
- Attempts count
- Best completion time
- Progress milestone reached
- Overall progress percentage

This design allows for efficient storage and retrieval of player progress across all levels while maintaining clear separation between top-level player data and individual level data.