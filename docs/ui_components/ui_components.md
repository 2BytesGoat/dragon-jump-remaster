---
title: UI Components Documentation
tags: [godot, game-engine, ui, user-interface, components]
related:
  - "[[player_system]]"
  - "[[leaderboard_system]]"
  - "[[save_system]]"
search_terms: [ui-components, menu-system, player-ui, leaderboard-ui, progress-bar, time-display, game-menus]
---

# UI Components Documentation

## Overview
The UI Components system provides all the user interface elements used throughout the Dragon Jump Remaster game. This includes main menus, level selection screens, end screens, progress indicators, and various other visual components that enhance player interaction with the game.

Key search terms and concepts for RAG retrieval: ui-components, menu-system, player-ui, leaderboard-ui, progress-bar, time-display, game-menus
System relationships and dependencies: This system integrates with player system for player data, save system for player names and stats, leaderboard system for score display, and main system for overall game flow.

## Script Components (`*.gd`)

### `main_menu.gd`
- **Purpose**: Main menu screen that provides access to different game modes and settings
- **Key properties**:
  - `tag_screen`: Reference to the player tag input screen
  - `level_select`: Path to level selection scene
  - `main_multiplayer`: Path to multiplayer training scene
- **Main methods**:
  - `_ready()`: Initializes menu state based on command line arguments
  - `_on_play_button_pressed()`: Handles play button press, shows tag screen if needed
  - `_on_quit_button_pressed()`: Exits the game
  - `_on_confirm_button_pressed()`: Processes player tag input and navigates to level select
  - `_on_skip_button_pressed()`: Skips player tag input and goes directly to level select
- **Integration points with other systems**:
  - Connects to SceneManger for scene navigation
  - Uses SaveManager to check player name
  - Integrates with EnvironmentVariables for command line arguments
  - Uses Constants for default player name
  - Uses Utils for player name validation
- **RAG metadata**: Performance considerations include efficient scene transitions, optimization hints involve preloading scenes and validating input early

### `end_screen.gd`
- **Purpose**: Displays game statistics when a run is completed
- **Key properties**:
  - None specific to the component
- **Main methods**:
  - `show_stats(stats: Dictionary)`: Displays player statistics in UI labels
- **Integration points with other systems**:
  - Updates UI labels with data from game stats
  - Connected to game completion events
- **RAG metadata**: Visual design patterns include simple panel layout with labeled statistics

### `progress_bar.gd`
- **Purpose**: Visual progress indicator showing player advancement in levels or races
- **Key properties**:
  - `x_start`: Starting x position for progress calculation
  - `x_length`: Total length of progress bar area
  - `player_with_crown`: Name of player currently holding the crown
  - `crown_shift_on_pickup`: Vertical shift when crown is picked up
- **Main methods**:
  - `_ready()`: Calculates progress bar dimensions on initialization
  - `update_player_progress(progress_data: Dictionary)`: Updates progress for players
  - `set_progress(node: Sprite2D, progress: float)`: Sets position of progress indicator
  - `_on_player_touched_crown(player: Player)`: Handles crown pickup event
  - `_on_player_dropped_crown(_player: Player)`: Handles crown drop event
- **Integration points with other systems**:
  - Uses SceneManger for scene navigation
  - Connects to player system for player events
  - Integrates with level system for progress tracking
- **RAG metadata**: UI flow considerations include smooth animations and proper positioning

## Scene Components (`*.tscn`)
### `main_menu.tscn`
- **Scene hierarchy and organization**: MarginContainer containing various UI elements including buttons, tag screen, and other menu components
- **Key connections between elements**:
  - Connects to button press signals for navigation
  - Links to tag_screen for player name input
  - Uses SceneManger for scene transitions
- **Visual layout considerations**: 
  - Uses MarginContainer for proper positioning
  - Includes responsive UI elements
- **RAG metadata**: Visual design patterns include layered containers, responsive layouts

### `end_screen.tscn`
- **Scene hierarchy and organization**: Simple Panel with labeled statistics (time, resets, crowns dropped)
- **Key connections between elements**:
  - Displays data passed from game logic
  - No complex connections beyond showing/hiding
- **Visual layout considerations**:
  - Clean panel layout for displaying stats
  - Labels positioned for clear readability
- **RAG metadata**: Visual design patterns include simple statistic display with clear labeling

### `progress_bar.tscn`
- **Scene hierarchy and organization**: MarginContainer containing texture panel and icon container with crown sprite
- **Key connections between elements**:
  - Connects to player events for crown handling
  - Uses Sprite2D nodes for visual progress indicators
- **Visual layout considerations**:
  - Horizontal layout for progress bar visualization
  - Crown icon that moves with player progress
- **RAG metadata**: Visual design patterns include progress visualization with moving elements

## System Integration
- How the system interacts with other components: UI components connect to various game systems through signals and data passing, providing visual feedback for player actions and game events
- Signal-based communication patterns: Uses SignalBus for communication between different systems, connects to player events for crown handling
- Data flow and control flow: Game data → Player system → UI components → Displayed to user
- Cross-system relationships for RAG linking: Related to player system (player events), save system (player data), leaderboard system (score display), main system (game flow)

## Design Patterns
- Architecture patterns used: Component pattern for UI elements, Observer pattern for event handling
- Code organization principles: Separation of concerns between UI presentation and game logic
- Reusability considerations: Progress bar component can be reused across different contexts
- Pattern-specific RAG tags and categorization: component-pattern, observer-pattern, ui-system

## Implementation Details
- Key code examples:
  - `SceneManger.go_to(level_select)` - Navigation between scenes
  - `set_progress(node, progress)` - Updating visual progress indicators
  - `show_stats(stats)` - Displaying game statistics
- Important algorithms or logic: 
  - Progress calculation based on x_start and x_length values
  - Player crown handling with vertical positioning shifts
  - Scene navigation with command-line argument checking
- Performance considerations: Efficient scene transitions, pre-calculated progress bar dimensions

## See Also
- [[player_system/player_system.md]]
- [[leaderboard_system/leaderboard_system.md]]
- [[save_system/save_system.md]]