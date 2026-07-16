---
title: Save System Documentation
tags: [godot, game-engine, save-system, data-persistence, player-progress]
related:
  - "[[main_system]]"
  - "[[player_system]]"
  - "[[level_system]]"
search_terms: [data-persistence, player-save, level-unlock, progress-tracking, game-state, resource-saving]
---

# Save System

## Overview

The Save System in Dragon Jump Remaster handles game state persistence, allowing players to save and load their progress across levels. It manages player data including level unlocks, completion times, and attempt counts. The system uses Godot's resource system to serialize and deserialize game data to/from disk.

## Script Components (`save_manager.gd`)

### Key Properties
| Property | Type | Purpose |
|----------|------|---------|
| `SAVE_PATH` | String | Format string for save file paths |
| `current_data` | GameData | Current loaded game data |
| `current_player_name` | String | Name of the currently active player |

### Main Methods and Functionality

#### `func _ready() -> void`
Initializes the SaveManager by loading existing game data and connecting to relevant signals:
- Calls `load_game()` to load existing save data
- Connects to `SignalBus.new_run_attempt` signal for tracking new attempts
- Connects to `SignalBus.new_time_submission` signal for handling time submissions

#### `func unlock_level(level_name: String)`
Unlocks a specific level by creating and adding a new LevelData entry for it in the current_data.levels dictionary if it doesn't already exist.

#### `func unlock_next_level(level_name: String)`
Unlocks the next level in sequence by finding the index of the current level and unlocking the subsequent one in Constants.LEVELS.keys().

#### `func save_to_disk()`
Saves the current game data to disk using Godot's ResourceSaver.save() method with a filename based on the current player name.

#### `func load_game()`
Loads existing game data from disk if it exists, otherwise creates a new save file for the current player. Uses ResourceLoader.exists() to check if a save file exists before attempting to load it.

#### `func create_new_save()`
Creates a new game save with default values, unlocks the first level defined in Constants.LEVELS, and saves it to disk. This is called when no existing save data is found for the current player name.

#### `func get_player_name() -> String`
Returns the player name from the current_data resource.

#### `func get_level_data(level_name: String) -> LevelData`
Retrieves the LevelData object for a specific level from current_data.levels.

#### `func has_level_data(level_name: String) -> bool`
Checks if level data exists for a given level name in current_data.levels.

#### `func update_level_progress(level_name: String) -> void`
Updates progress tracking for a level based on the best time compared to milestone times defined in Constants.LEVELS.

#### `func _on_new_run_attempt(level_name: String) -> void`
Handles new run attempts by incrementing the attempt count for a level and saving the data.

#### `func _on_new_time_submission(level_name: String, time: float) -> void`
Handles new time submissions by updating the best time if it's better than the current best, updating progress, unlocking the next level, and emitting a leaderboard submission signal.

#### `func _on_player_name_changed(value) -> void`
Handles player name changes by updating the current_player_name property, clearing current_data, and reloading the game data with the new player name.

### Signals and Connections
- `SignalBus.new_run_attempt` - Connected to `_on_new_run_attempt()` method
- `SignalBus.new_time_submission` - Connected to `_on_new_time_submission()` method

## System Integration

The SaveManager works as a singleton that integrates with other systems through:
1. Signal-based communication with the SignalBus
2. Integration with Constants for level definitions and time milestones
3. Interaction with GameData and LevelData resources for data storage
4. Connection to the LeaderboardManager via `SignalBus.new_leaderboard_submission` signal

## Design Patterns

### Singleton Pattern
The SaveManager is implemented as a singleton, accessible globally through Godot's autoload system.

### Resource-based Data Persistence
Uses Godot's built-in resource system (ResourceSaver/ResourceLoader) for efficient data serialization and persistence.

### Signal-driven Architecture
Follows Godot's event-driven architecture by connecting to and emitting signals rather than maintaining direct references between systems.

## Data Flow

1. **Initialization**: SaveManager loads existing data or creates new save on startup
2. **New Run Attempt**: When a player starts a level, `new_run_attempt` signal is emitted → `_on_new_run_attempt()` increments attempts and saves
3. **Time Submission**: When a player completes a level, `new_time_submission` signal is emitted → `_on_new_time_submission()` updates best times, progress, unlocks next level, and submits to leaderboard
4. **Data Persistence**: All changes are saved to disk using `save_to_disk()`

## File Structure

### Save File Location
Save files are stored in Godot's user:// directory with the format: `user://[player_name]_savegame.tres`

### Data Resources
- `GameData` - Top-level resource containing player name and levels dictionary
- `LevelData` - Resource for each level containing attempts, best_time, progress_milestone, and progress_percentage