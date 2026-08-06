---
title: SignalBus Singleton Documentation
tags: [godot, game-engine, communication, signals, singleton]
related:
  - "[[technical/rl-integration]]"
  - "[[technical/player-system]]"
  - "[[technical/save-system/index]]"
search_terms: [signal communication, event bus, inter-system communication, signal broadcasting, game events]
---

# SignalBus Singleton

## Overview

The SignalBus singleton serves as a centralized communication hub for the Dragon Jump Remaster game. It provides a standardized way for different systems to communicate with each other through signals, enabling loose coupling between components while maintaining clear data flow and event handling throughout the game architecture.

## Script Components (`signal_bus.gd`)

### Key Properties
- None - This is a singleton that only defines signals

### Main Functionality
The SignalBus singleton acts as an event bus that allows various systems to emit and listen to signals without having direct references to each other. It facilitates communication between:
- Player system components
- Save system for progress tracking
- RL integration system for training events
- Leaderboard system for score submissions

### Signals and Connections

> [!NOTE]
> Player lifecycle signals (`run_started`, `run_restarted`, `run_finished`, `died`) **do not live on SignalBus** — they are emitted by the `Player` node itself and consumed via direct connections (e.g. `main.gd`, `run_timer.gd`). SignalBus carries only cross-scene signals.

| Signal | Parameters | Description |
|--------|------------|-------------|
| `new_run_attempt(level_name)` | level_name: String | Emitted when a new run attempt begins for a specific level (also on manual restart) |
| `new_time_submission(level_name, time)` | level_name: String, time: float | Emitted when a new time is submitted for a level (only on run finish) |
| `play_time_elapsed(seconds)` | seconds: float | Emitted when active play time accumulates (flushed on restart/finish/exit and periodically); drives retention "time played" counters |

## System Integration

### Signal-based Communication Patterns
The SignalBus enables a publish-subscribe pattern where:
1. Systems emit signals when specific events occur
2. Other systems connect to these signals to respond appropriately
3. This decouples system components while maintaining clear communication paths

### Data Flow and Control Flow
1. **Event Emission**: Various game systems emit signals through SignalBus when events occur
2. **Signal Handling**: Connected systems receive and process the emitted signals
3. **Data Propagation**: Event data flows through the system without tight coupling

### Cross-system Relationships for RAG Linking
- [[technical/rl-integration]] - Connects to RL training events and agent actions
- [[technical/player-system]] - Handles player-related events and state changes
- [[technical/save-system/index]] - Processes time submissions and progress tracking
- [[technical/leaderboard]] - Manages leaderboard updates and score submissions

## Design Patterns

### Event Bus Pattern
Implements the event bus pattern to facilitate loose coupling between game systems, allowing components to communicate without direct dependencies.

### Singleton Pattern
Uses the singleton pattern to ensure there's only one instance of the signal bus throughout the game, providing a consistent communication point.

### RAG Tags and Categorization
- communication-system
- event-bus
- signal-management
- inter-system-communication
- game-events

## Implementation Details

### Key Code Examples
```gdscript
# Emitting a signal from a level start
SignalBus.new_run_attempt.emit(level_name)

# Connecting to a signal in the save system
SignalBus.new_time_submission.connect(_on_new_time_submission)

# Listening to player lifecycle signals directly on the player node
player.run_finished.connect(_on_player_run_finished)
```

### Performance Considerations
- SignalBus is lightweight as it only defines signals without complex logic
- Signal emission has minimal performance overhead
- Proper signal disconnection is important to prevent memory leaks

### Optimization Hints
- Always disconnect signals when objects are freed to prevent memory leaks
- Use signal parameters efficiently to avoid unnecessary data transfer
- Group related events into appropriate signal categories for better organization

## File Structure

### Location
SignalBus singleton is stored in `src/scripts/singletons/signal_bus.gd` and is automatically loaded as a singleton in the game.

### Usage in Game Architecture
The SignalBus singleton is accessed from any system that needs to emit or connect to signals. It's typically used for:
- Player state management events
- Progress tracking and save system communication
- RL training integration events
- Leaderboard score submissions

## Relationship with Other Systems

SignalBus works in conjunction with other systems through signal connections:
- Game systems emit signals when events occur
- Save system connects to time submission signals to track progress
- RL integration system listens to player events for training data
- Leaderboard system responds to score submission signals to update rankings

This design allows for flexible, scalable communication between game components while maintaining clear separation of concerns.