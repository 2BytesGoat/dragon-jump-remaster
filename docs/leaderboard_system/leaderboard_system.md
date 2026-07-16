---
title: Leaderboard System Documentation
tags: [godot, game-engine, ui, networking, leaderboard]
related: [[save_system/save_system.md]], [[player_system/player_system.md]], [[ui_components/ui_components.md]]
search_terms: [leaderboard, scores, multiplayer, silentwolf, online-leaderboards, time-submission, player-rankings]
---

# Leaderboard System Documentation

## Overview
The Leaderboard System manages player performance tracking and displays rankings for different levels. It integrates with the SilentWolf plugin to provide online leaderboard functionality while maintaining a local cache for offline access. The system handles both displaying existing scores and submitting new times to leaderboards.

Key search terms and concepts for RAG retrieval: leaderboard, scores, multiplayer, silentwolf, online-leaderboards, time-submission, player-rankings
System relationships and dependencies: This system integrates with SaveManager for player data, SignalBus for communication, and SilentWolf plugin for online score management.

## Script Components (`*.gd`)

### `leaderboard_manager.gd`
- **Purpose**: Manages local leaderboard cache and handles communication with the SilentWolf plugin for online leaderboards
- **Key properties**:
  - `NB_RETRIEVED_ENTRIES`: Number of entries to retrieve from the online leaderboard (set to 10)
  - `leaderboard_cache`: Dictionary storing cached leaderboard data for different levels
- **Main methods**:
  - `_ready()`: Initializes signal connection to new leaderboard submissions
  - `get_local_leaderboard(leaderboard_name: String)`: Returns cached leaderboard data for a specific level
  - `update_local_leaderboard(leaderboard_name: String)`: Fetches updated scores from SilentWolf and updates local cache
  - `_on_new_leaderboard_submission(player_name, level_name, time)`: Handles new score submissions to the online leaderboard
- **Signals**:
  - `new_leaderboard_submission`: Emitted when a new score is submitted
- **Integration points with other systems**:
  - Connects to SignalBus for communication
  - Uses SaveManager to get player's best time for a level
  - Integrates with SilentWolf plugin for online leaderboard operations
- **RAG metadata**: Performance considerations include caching to reduce network requests, optimization hints involve using local cache for better responsiveness

### `leaderboard.gd`
- **Purpose**: UI component that displays leaderboard entries in the game interface
- **Key properties**:
  - `MAX_SUPPORTED_ENTRIES`: Maximum number of entries to display (set to 9)
  - `leaderboard_entry_container`: Reference to container holding leaderboard entries
  - `leaderboard_placeholder_label`: Label shown when loading leaderboard data
  - `server_error_label`: Label shown when leaderboard fetch fails
  - `leaderboard_entry_scene`: Preloaded scene for individual leaderboard entries
  - `leaderboard_others_scene`: Preloaded scene for "others" label when player is not in top scores
- **Main methods**:
  - `_ready()`: Connects to leaderboard_scores_updated signal
  - `update_leaderboard(level_name: String)`: Updates the UI with leaderboard data for a specific level
- **Integration points with other systems**:
  - Listens to SignalBus.leaderboard_scores_updated signal
  - Uses LeaderboardManager to get cached leaderboard data
  - Integrates with SaveManager to get player name
  - Uses Utils for time formatting
- **RAG metadata**: Visual design patterns include container-based layout, error handling for network issues

### `leaderboard_entry.gd`
- **Purpose**: Individual UI element representing a single leaderboard entry
- **Key properties**:
  - `player_name_label`: Label displaying player name
  - `player_score_label`: Label displaying player score/time
  - `player_name`: String property to set the player name
  - `player_score`: String property to set the player score
- **Main methods**:
  - `_ready()`: Sets labels with provided player name and score
- **Integration points with other systems**:
  - Used by leaderboard.gd to display individual entries
- **RAG metadata**: UI flow considerations include proper label sizing and alignment

## Scene Components (`*.tscn`)
### `leaderboard.tscn`
- **Scene hierarchy and organization**: MarginContainer containing EntryContainer, LeaderboardPlaceholderLabel, and ServerErrorLabel
- **Key connections between elements**:
  - Connects to SignalBus.leaderboard_scores_updated signal for updates
  - Uses preloaded scenes for individual entries and "others" labels
- **Visual layout considerations**: 
  - Uses MarginContainer for proper positioning
  - Includes placeholder and error states for better UX
- **RAG metadata**: Visual design patterns include layered containers, state management for loading/error conditions

### `leaderboard_entry.tscn`
- **Scene hierarchy and organization**: HBoxContainer with two labels (player name and score)
- **Key connections between elements**:
  - Simple layout with no complex connections
- **Visual layout considerations**:
  - Horizontal layout for player name and score display
  - Uses standard label controls for text rendering
- **RAG metadata**: Visual design patterns include simple horizontal alignment

## System Integration
- How the system interacts with other components: The leaderboard system connects to SignalBus for communication, uses SaveManager for player data, and integrates with SilentWolf plugin for online functionality
- Signal-based communication patterns: Uses SignalBus.leaderboard_scores_updated to notify UI when leaderboard data is updated
- Data flow and control flow: Player data → SaveManager → LeaderboardManager → SilentWolf → LeaderboardManager cache → UI update
- Cross-system relationships for RAG linking: Related to SaveManager (player data), SignalBus (communication), SilentWolf (online functionality)

## Design Patterns
- Architecture patterns used: Singleton pattern for leaderboard manager, Observer pattern for signal-based updates
- Code organization principles: Separation of concerns between data management and UI presentation
- Reusability considerations: Leaderboard entry component is reusable across different UI contexts
- Pattern-specific RAG tags and categorization: singleton, observer-pattern, ui-component

## Implementation Details
- Key code examples:
  - `leaderboard_cache[leaderboard_name] = {"status": "updating", "scores": {}}` - Setting up cache structure
  - `SilentWolf.Scores.get_score_position(player_best_time).sw_get_position_complete` - Async call to SilentWolf
- Important algorithms or logic: 
  - Caching mechanism to reduce network calls
  - Player ranking calculation based on time comparison
  - UI rendering logic that handles player not in top scores
- Performance considerations: Caching reduces server requests, async operations prevent UI freezing

## See Also
- [[save_system/save_system.md]]
- [[player_system/player_system.md]]
- [[ui_components/ui_components.md]]