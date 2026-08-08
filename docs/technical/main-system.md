---
title: Main System Documentation
tags: [godot, game-engine, main-system, game-loop, level-management]
related:
  - "[[technical/player-system]]"
  - "[[technical/level-system/index]]"
  - "[[technical/save-system/index]]"
search_terms: [main-loop, game-flow, level-loading, player-management, signal-communication, ui-handling]
---

# Main System Documentation

This document describes the core game system that orchestrates the overall gameplay flow in Dragon Jump Remaster.

## Overview

The `main.gd` script serves as the central hub of the game, managing the coordination between different systems including level loading, player management, camera control, UI handling, and game state transitions. The main scene (`main.tscn`) provides the container structure for all game components.

## Main Game Loop (`main.gd`)

### Core Functionality

The `main.gd` script manages the core gameplay loop by:
- Initializing level, player, camera, and UI components
- Handling level transitions and resets
- Managing game state (paused, finished)
- Coordinating player actions and signals
- Handling scene navigation and game progression

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `level` | Node2D | Reference to the level scene |
| `player_container` | Node2D | Container for player instances |
| `camera` | Camera2D | Main camera instance |
| `card_container` | VBoxContainer | Container for power-up cards |
| `level_music` | AudioStreamPlayer | Background music player |
| `pause_screen` | MarginContainer | Pause screen UI element |
| `end_screen` | MarginContainer | End game screen UI element |
| `run_timer` | RunTimer | Run clock (single source of truth for run time; lives at the Main root) |
| `time_container` | TimeDisplay | Run timer UI label (display-only, lives inside `ArcadeRankHud`; see [[technical/ui/arcade-hud]]) |

### Key Methods

#### `_ready()`
Initializes the game by:
- Stopping menu music via `AudioManager.stop_music()` (the menu's "Groovy booty" track runs through the persistent `AudioManager`; the game's own `AudioStreamPlayer` takes over from here)
- Loading level data via the `SceneLoader` autoload; if `GameSession.custom_level_code` is set, loads the level directly from the code string instead of a campaign resource (custom levels, see [[technical/ui/index]] § custom_levels_menu)
- Setting up the player with appropriate starting position and speed modifier
- Connecting signal handlers for player events
- Initializing UI states

#### `initialize_players()`
Creates and configures the player instance with:
- Proper positioning and controller type
- Camera linking to the player
- Signal connections for reset handling
- `run_timer.track_player()` to wire the run clock to player lifecycle signals

#### `update_players()`
Resets all players to their initial state with:
- Updated starting positions
- New speed modifiers
- Reset flags and states

#### `set_game_paused(value: bool)`
Controls game pause state by:
- Setting pause flag on all players
- Toggling visibility of pause screen
- Emitting game_paused signal

#### `reset_ui()`
Resets UI elements to initial state by:
- Clearing pause state
- Resetting time container
- Setting race finished flag to false

### Signals

| Signal | Description |
|--------|-------------|
| `game_paused` | Emitted when game pause state changes |

### Connections

The main scene connects to various signals from child components:
- Player restarts and finishes
- UI button presses (pause, restart, exit, next)
- Level size updates for particle effects and camera

## Main Scene Structure (`main.tscn`)

The main scene serves as the container for all game elements and manages their relationships.

### Scene Hierarchy

```
Main (Node)
├── RunTimer (Run clock: total_time + play-time accumulation)
├── SubViewportContainer
│   └── SubViewport
│       ├── ScreenShake
│       ├── HitStop
│       ├── GPUParticles2D (Background particles)
│       ├── Level (Level scene instance)
│       ├── Camera2D (Camera instance)
│       ├── Players (Player container)
│       ├── CanvasLayer
│       │   ├── CardContainerContainer (Power-up cards)
│       │   ├── PauseScreen (Pause UI)
│       │   ├── EndScreen (End game UI)
│       │   ├── ArcadeGameOverScreen
│       │   ├── ArcadeRankHud
│       │   │   └── TimeContainer (Run timer label — display only)
│       │   └── TransitionWipe
│       └── AudioStreamPlayer (Music player)
└── CRTScreenEffect (Visual effect)
```

### Key Connections

The scene handles various signal connections:
- `game_paused` → `RunTimer` (pause gate for the clock)
- `RunTimer.time_changed` → `ArcadeRankHud/TimeContainer.set_time` (drives the HUD label)
- `level_size_updated` → GPUParticles2D and Camera2D
- UI button presses to corresponding handler methods

## Integration Points

### With Level System
- Loads level data using the `SceneLoader` autoload
- Updates level with new codes via `update_level()` method

### With Player System
- Creates and manages player instances
- Handles player restart and finish events

### With UI System
- Controls visibility of pause and end screens
- Pushes run time into the HUD: `run_timer.track_player()` wires player signals, `arcade_rank_hud.run_timer` gives the HUD read access, and the `time_changed` connection drives the label
- Handles scene transitions

### With SignalBus
- Emits `new_run_attempt` and `new_time_submission` for save/progress tracking
- Player lifecycle signals (`run_started`, `run_restarted`, `run_finished`, `died`) are consumed directly from the player node (e.g. by `main.gd` and `RunTimer`)

## Game Flow

1. **Initialization**: Level data loaded, players created, UI initialized
2. **Gameplay**: Players navigate level, collect items, avoid obstacles
3. **Completion**: Player finishes level, time recorded, end screen shown
4. **Restart/Next**: Player can restart current level or advance to next

## Key Design Patterns

- **Centralized Control**: All game coordination happens in this main script
- **Signal-Based Communication**: Systems communicate through signals rather than direct references
- **Scene-Based Architecture**: Each system has its own scene for easy replacement and iteration