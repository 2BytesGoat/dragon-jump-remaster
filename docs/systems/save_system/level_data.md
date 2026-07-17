---
title: LevelData Resource Documentation
tags: [godot, game-engine, data-management, resource-system]
related:
  - "[[save_system]]"
  - "[[game_data]]"
search_terms: [level progress, player statistics, game data tracking, level completion, time recording]
---

# LevelData Resource

## Overview

The `LevelData` resource in Dragon Jump Remaster represents individual level progress information for a player. It stores specific metrics and statistics related to a player's performance on a particular level, enabling detailed tracking of completion times, attempts, and progress milestones. This resource is used as part of the GameData structure to maintain comprehensive player progress data.

### Key Search Terms and Concepts
- Level progress tracking
- Player statistics recording
- Game data persistence
- Time-based performance metrics
- Progress milestone indicators

### Role within Overall Architecture
LevelData serves as a critical component in the save system architecture, working alongside GameData and SaveManager to maintain persistent player progress across game sessions. It provides structured data storage for individual level completion information while integrating seamlessly with the broader game state management system.

## Script Components (`level_data.gd`)

### Key Properties

| Property | Type | Purpose |
|----------|------|---------|
| `attempts` | int | Number of attempts made on this level |
| `best_time` | float | Best completion time recorded for this level (INF if not completed) |
| `progress_milestone` | int | Milestone reached in this level's progress (0-3) |
| `progress_percentage` | float | Overall percentage of level completion (0.0-100.0) |

### Main Functionality

The LevelData resource is designed as a simple data container that tracks player performance metrics for individual levels. It does not contain any methods or logic, serving purely as a structured way to store level-specific progress information including:
- Attempt count tracking
- Best time recording (with INF representing no completion)
- Progress milestone indicators (0-3 scale)
- Overall completion percentage

## System Integration

The LevelData resource integrates with the SaveManager singleton and GameData structure through the following mechanisms:

### Signal-based Communication Patterns
- LevelData objects do not emit signals directly, but are updated through SaveManager's signal connections
- SaveManager connects to game events (level completion, attempt start) to update LevelData properties

### Data Flow and Control Flow
1. **Initialization**: When a new GameData instance is created, each level gets a default LevelData object with zero attempts and INF best time
2. **Progress Updates**: As players complete levels, SaveManager updates the corresponding LevelData properties (attempts, best_time, progress_milestone, progress_percentage)
3. **Persistence**: LevelData objects are automatically serialized when GameData is saved to disk using ResourceSaver.save()
4. **Loading**: When loading game state, LevelData objects are automatically deserialized from disk through ResourceLoader.load()

### Cross-system Relationships for RAG Linking
- [[save_manager]] - Primary system that updates and manages LevelData objects
- [[game_data]] - Container that holds all LevelData objects in the levels dictionary
- [[player_progress_system]] - System that uses LevelData for progress tracking and UI display


## Design Patterns

### Resource-based Data Structure
Uses Godot's built-in Resource system for efficient serialization and deserialization of level progress data, allowing automatic persistence between game sessions.

### Metric-based Progress Tracking
Organizes progress information into specific numerical metrics that can be easily compared, displayed, and used for game progression logic or leaderboard calculations.

### RAG Tags and Categorization
- data-management
- resource-system
- player-progress
- game-state
- statistics-tracking

## Implementation Details

### Key Code Examples
```gdscript
# Creating a new LevelData object
var level_data = preload("res://src/scripts/resources/level_data.gd").new()

# Updating progress
level_data.attempts += 1
if level_data.best_time > time or level_data.best_time == INF:
    level_data.best_time = time

# Accessing data for UI display
var progress_text = "Level %s: %d attempts, Best time: %.2f" % [level_name, level_data.attempts, level_data.best_time]
```

### Performance Considerations
- LevelData objects are lightweight resources with minimal memory footprint
- Serialization is handled automatically by Godot's Resource system
- Data access patterns are optimized for frequent read operations during gameplay

### Optimization Hints
- Use LevelData objects as read-only references when displaying progress information
- Cache frequently accessed properties to avoid repeated dictionary lookups
- Consider using a singleton pattern for accessing the current level's LevelData object for better performance


## Data Flow

1. **Initialization**: When a new GameData instance is created, each level gets a default LevelData object with zero attempts and INF best time
2. **Progress Updates**: As players complete levels, SaveManager updates the corresponding LevelData properties (attempts, best_time, progress_milestone, progress_percentage)
3. **Persistence**: LevelData objects are automatically serialized when GameData is saved to disk using ResourceSaver.save()
4. **Loading**: When loading game state, LevelData objects are automatically deserialized from disk through ResourceLoader.load()

## File Structure

### Location
LevelData resources are stored in `src/scripts/resources/level_data.gd` and are used by the SaveManager singleton as part of GameData structures.

### Usage in Save System
Each LevelData resource is a component of the GameData.levels dictionary where keys are level names (e.g., "1-1", "1-2") and values are LevelData instances. This structure allows efficient access to progress data for any specific level while maintaining organized data organization across all levels in the game.

### RAG Metadata
- File location: `src/scripts/resources/level_data.gd`
- Resource type: Godot Resource
- Data persistence pattern: Automatic serialization through SaveManager
- Integration point: GameData.levels dictionary
- Performance considerations: Lightweight resource with minimal memory footprint


## Relationship with GameData

LevelData works in conjunction with GameData resources through the `levels` dictionary in GameData. The relationship is structured as follows:
- GameData contains a `levels` dictionary property
- Each key in this dictionary corresponds to a level name (e.g., "1-1")
- Each value is a LevelData resource containing specific progress information for that level

This design allows for efficient storage and retrieval of player progress across all levels while maintaining clear separation between top-level player data (GameData) and individual level data (LevelData).