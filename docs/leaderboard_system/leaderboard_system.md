---
title: Leaderboard System
author: Cline
status: Draft
---

**Overview**: This document details the leaderboard system implementation, including score tracking, event integration, and local storage mechanisms.

# Leaderboard System

**Location**: `src/scripts/leaderboard_manager.gd` (singleton)  
**Purpose**: Track and manage high scores between game runs

#### Key Features
- Persistent local storage of high scores
- Integration with game state transitions
- Simple score comparison and storage

#### Implementation Details
- **Event Integration**: 
  - Triggered by `player_finished_run` signal from `level.gd`
  - Stores score via `save_manager` integration points
- **Storage Mechanism**: 
  - Local file storage (no cloud services)
  - Simple key-value format (player name → score)
- **Data Flow**:
  ```mermaid
  graph LR
    level.gd -->|player_finished_run| LeaderboardManager
    LeaderboardManager -->|save| save_manager.gd
  ```

#### References
- `level.gd`: `player_finished_run` signal source
- `leaderboard_manager.gd`: Singleton implementation
- `save_system.md`: Storage integration points
- `player_system.md`: Player state context for score calculation