---
title: UI Components Documentation
tags: [godot, game-engine, ui, user-interface, components]
related:
  - "[[technical/player-system]]"
  - "[[technical/leaderboard]]"
  - "[[technical/save-system/index]]"
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
  - `settings_menu`: Reference to the sound settings modal
  - `credits_screen`: Reference to the rolling credits overlay
- **Layout** (compact arcade style): primary column of PLAY / PRACTICE / CREATE, then a footer row of small buttons: SETTINGS / CREDITS / DISCORD / WEB / QUIT
- **Main methods**:
  - `_ready()`: Initializes menu state based on command line arguments
  - `_on_play_button_pressed()`: Handles play button press, starts an arcade run
  - `_on_practice_button_pressed()`: Sets practice mode and navigates to level select
  - `_on_create_button_pressed()`: Navigates to the custom levels menu
  - `_on_credits_button_pressed()`: Shows the rolling credits overlay
  - `_on_discord_button_pressed()` / `_on_website_button_pressed()`: Open social links via `OS.shell_open()` (URLs in `Constants.DISCORD_URL` / `Constants.WEBSITE_URL`)
  - `_on_quit_button_pressed()`: Exits the game
  - `_on_confirm_button_pressed()`: Processes player tag input and navigates to level select
  - `_on_skip_button_pressed()`: Skips player tag input and goes directly to level select
- **Integration points with other systems**:
  - Connects to the `SceneLoader` autoload for scene navigation
  - Uses SaveManager to check player name
  - Uses Constants for default player name and social URLs
  - Uses Utils for player name validation
- **RAG metadata**: Performance considerations include efficient scene transitions, optimization hints involve preloading scenes and validating input early

### `custom_levels_menu.gd` / `custom_levels_menu.tscn`
- **Purpose**: Browse imported custom levels, import new ones by pasting a level code (name + code via `LevelCodeParser` validation), play them, or delete them. Levels persist via `CustomLevelStore` (`user://custom_levels.json`).
- **Main methods**:
  - `_ready()`: Refreshes the level list and focuses import
  - `_on_play_button_pressed()`: Calls `GameSession.start_custom_run(code)` and navigates to the game scene
  - `_on_import_confirm_pressed()`: Validates and stores an imported level
  - `_on_delete_button_pressed()`: Removes the selected level
  - `_on_back_button_pressed()`: Returns to the main menu
- **Integration points**: `CustomLevelStore` (persistence), `LevelCodeParser` (validation), `GameSession` (custom run), `SceneLoader`

### `credits_screen.gd` / `credits_screen.tscn`
- **Purpose**: Full-screen overlay with a Star Wars-style rolling text crawl. Closes on `ui_accept` / `ui_cancel` / mouse click.
- **Main methods**:
  - `reset_crawl()`: Restarts the crawl from below the screen
  - `close()`: Hides the overlay
- **Integration points**: Embedded in `main_menu.tscn` as `SubViewport/SubViewport/CreditsScreen`; toggled by `main_menu.gd`

### `custom_level_store.gd`
- **Purpose**: Static helper (not an autoload) that persists player-imported custom levels to `user://custom_levels.json` as `{ id: { "name", "code" } }`.
- **Main methods**: `get_all()`, `get_level(id)`, `has_level(id)`, `add_level(id, name, code)`, `remove_level(id)`

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

### `single_time_container.gd` / `arcade_rank_hud.tscn`
- **Purpose**: Run timer + play-time accumulation, embedded in the arcade HUD (`TimeContainer`).
- Documented in [[technical/ui/arcade-hud]]. See that doc for the player-signal flow and flush points; `src/ui/components/time_container.tscn` is a stale, unused draft.

### `bonus_popup.gd` / `bonus_popup.tscn` / `bonus_popup_config.tres`
- **Purpose**: Reusable one-shot "+bonus" popup that animates above a world position and frees itself. Spawned by `ArcadeRankHud` at level clear and by `BonusPopup.spawn()` from anywhere; timing tuned via `resources/bonus_popup_config.tres`.
- Documented in [[technical/ui/arcade-hud]].

### `progress_bar.gd` *(removed)*
Progress-bar mode was cut for V1.0 (see [[technical/architecture]]). No such file exists in the repo.

## Scene Components (`*.tscn`)
### `main_menu.tscn`
- **Scene hierarchy and organization**: MarginContainer containing logo, primary button column (PLAY / PRACTICE / CREATE), footer row (SETTINGS / CREDITS / DISCORD / WEB / QUIT), tag screen, settings modal, and credits overlay
- **Key connections between elements**:
  - Connects to button press signals for navigation
  - Links to tag_screen for player name input
  - Links to settings_menu and credits_screen as overlays
  - Uses the `SceneLoader` autoload for scene transitions
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

### `progress_bar.tscn` *(removed)*
No such file exists in the repo.

### `arcade_rank_hud.tscn` / `time_container.tscn`
- **Purpose**: `arcade_rank_hud.tscn` is the live gameplay HUD (lives, timer, rank bar, score). Its nested `TimeContainer` runs `single_time_container.gd` — see the Script Components section above.
- `time_container.tscn` is a **stale, unused** draft scene; the live timer is inside `arcade_rank_hud.tscn` (main.tscn:57).

## System Integration
- How the system interacts with other components: UI components connect to various game systems through signals and data passing, providing visual feedback for player actions and game events
- Signal-based communication patterns: UI components consume player lifecycle signals (`run_started`, `run_restarted`, `run_finished`) directly and use SignalBus for cross-scene events (e.g. `play_time_elapsed` for the retention timer)
- Data flow and control flow: Game data → Player system → UI components → Displayed to user
- Cross-system relationships for RAG linking: Related to player system (player events), save system (player data), leaderboard system (score display), main system (game flow)

## Design Patterns
- Architecture patterns used: Component pattern for UI elements, Observer pattern for event handling
- Code organization principles: Separation of concerns between UI presentation and game logic
- Reusability considerations: Shared menu and HUD components can be reused across contexts
- Pattern-specific RAG tags and categorization: component-pattern, observer-pattern, ui-system

## Implementation Details
- Key code examples:
  - `SceneLoader.go_to(level_select)` - Navigation between scenes
  - `show_stats(stats)` - Displaying game statistics
- Important algorithms or logic: 
  - Scene navigation with command-line argument checking
- Performance considerations: Efficient scene transitions, preloaded scenes

## See Also
- [[technical/player-system]]
- [[technical/leaderboard]]
- [[technical/save-system/index]]