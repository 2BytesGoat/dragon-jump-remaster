---
title: Main System Documentation
tags: [godot, game-engine, main-system, game-loop, level-management]
related:
  - "[[player_system]]"
  - "[[level_system]]"
  - "[[save_system]]"
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
| `time_container` | MarginContainer | Time tracking UI element |

### Key Methods

#### `_ready()`
Initializes the game by:
- Loading level data from `SceneManager` (currently named `SceneManger` in code; rename pending)
- Setting up the player with appropriate starting position and speed modifier
- Connecting signal handlers for player events
- Initializing UI states

#### `initialize_players()`
Creates and configures the player instance with:
- Proper positioning and controller type
- Camera linking to the player
- Signal connections for reset handling

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
├── SubViewportContainer
│   └── SubViewport
│       ├── GPUParticles2D (Background particles)
│       ├── Level (Level scene instance)
│       ├── Camera2D (Camera instance)
│       ├── Players (Player container)
│       ├── CanvasLayer
│       │   ├── CardContainerContainer (Power-up cards)
│       │   ├── PauseScreen (Pause UI)
│       │   ├── EndScreen (End game UI)
│       │   └── TimeContainer (Time tracking)
│       └── AudioStreamPlayer (Music player)
└── CRTScreenEffect (Visual effect)
```

### Key Connections

The scene handles various signal connections:
- `game_paused` → TimeContainer
- `level_size_updated` → GPUParticles2D and Camera2D
- UI button presses to corresponding handler methods

## Integration Points

### With Level System
- Loads level data using `SceneManager` (currently named `SceneManger` in code; rename pending)
- Updates level with new codes via `update_level()` method

### With Player System
- Creates and manages player instances
- Handles player restart and finish events

### With UI System
- Controls visibility of pause and end screens
- Manages time tracking display
- Handles scene transitions

### With SignalBus
- Uses signals for game progression events
- Listens to player restart/finish events

## Game Flow

1. **Initialization**: Level data loaded, players created, UI initialized
2. **Gameplay**: Players navigate level, collect items, avoid obstacles
3. **Completion**: Player finishes level, time recorded, end screen shown
4. **Restart/Next**: Player can restart current level or advance to next

## Key Design Patterns

- **Centralized Control**: All game coordination happens in this main script
- **Signal-Based Communication**: Systems communicate through signals rather than direct references
- **Scene-Based Architecture**: Each system has its own scene for easy replacement and iteration