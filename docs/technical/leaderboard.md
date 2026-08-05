---
title: Leaderboard System Documentation
tags: [godot, game-engine, ui, leaderboard]
related:
  - "[[technical/save-system/index]]"
  - "[[technical/player-system]]"
  - "[[technical/ui/index]]"
search_terms: [leaderboard, scores, local-leaderboard, time-submission, player-rankings]
---

# Leaderboard System Documentation

## Overview
The Leaderboard System displays performance rankings for each level. **Online leaderboards (`LeaderboardManager` + SilentWolf) are deferred to the 1.0 build** (Phase 3; see [[technical/architecture]]). In EA the system is a **local UI stub only**: `leaderboard.gd` renders a "Leaderboard disabled in V1.0." placeholder, and the local arcade run summary is tracked by `ArcadeDirector`.

> **1.0 leaderboard split (2026-08-05 decision, [[project/decisions]]):** campaign levels use Steam leaderboards (permanent, prestigious); daily/weekly challenges and world arcade use SilentWolf (time-windowed, no manual clearing).

Key search terms and concepts for RAG retrieval: leaderboard, scores, local-leaderboard, time-submission, player-rankings
System relationships and dependencies: This system is a presentation layer. It does not depend on a leaderboard manager in V1.0; `SaveManager` remains the source of truth for local best times.

## Script Components (`*.gd`)

### `leaderboard.gd`
- **Purpose**: UI component that displays leaderboard entries. In V1.0 it shows a placeholder and intentionally does not fetch scores.
- **Key properties**:
  - `MAX_SUPPORTED_ENTRIES`: Maximum number of entries to display (set to 9)
  - `leaderboard_entry_container`: Reference to container holding leaderboard entries
  - `leaderboard_placeholder_label`: Label shown when leaderboard data is unavailable
  - `server_error_label`: Label shown when a leaderboard fetch fails
  - `leaderboard_entry_scene`: Preloaded scene for individual leaderboard entries
  - `leaderboard_others_scene`: Preloaded "others" label scene
- **Main methods**:
  - `_ready()`: Shows the V1.0 placeholder
  - `update_leaderboard(level_name: String)`: Shows the V1.0 placeholder (no-op in V1.0)
- **Integration points with other systems**:
  - Consumed by `level_select.gd` and `end_screen.gd` via `%Leaderboard`
  - Post-launch: expects a leaderboard manager + `SignalBus.leaderboard_scores_updated` signal
- **RAG metadata**: Placeholder-driven UI; rendering path for real entries already scaffolded but unused in V1.0.

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
  - Used by `leaderboard.gd` to display individual entries
- **RAG metadata**: Reusable single-entry component.

## Scene Components (`*.tscn`)
### `leaderboard.tscn`
- **Scene hierarchy and organization**: MarginContainer containing EntryContainer, LeaderboardPlaceholderLabel, and ServerErrorLabel
- **Key connections between elements**:
  - Post-launch: expects to listen to `SignalBus.leaderboard_scores_updated`
  - Uses preloaded scenes for individual entries and "others" labels
- **Visual layout considerations**:
  - Uses MarginContainer for proper positioning
  - Includes placeholder and error states for better UX

### `leaderboard_entry.tscn`
- **Scene hierarchy and organization**: HBoxContainer with two labels (player name and score)
- **Visual layout considerations**:
  - Horizontal layout for player name and score display

## System Integration
- How the system interacts with other components: In V1.0 the leaderboard is a self-contained UI stub invoked by `level_select.gd` and `end_screen.gd`
- Signal-based communication patterns: No active signal usage in V1.0; `SignalBus.leaderboard_scores_updated` reserved for post-launch
- Data flow and control flow: Post-launch: Player data → SaveManager → LeaderboardManager → SilentWolf → cache → UI update
- Cross-system relationships for RAG linking: Related to SaveManager (player data), UI components (menus), ArcadeDirector (local run summary)

## Design Patterns
- Architecture patterns used: Observer pattern reserved for signal-based updates; component-per-entry UI composition
- Code organization principles: Separation of concerns between data management (post-launch) and UI presentation
- Reusability considerations: Leaderboard entry component is reusable across different UI contexts

## Implementation Details
- Key code examples:
  - `_show_placeholder("Leaderboard disabled in V1.0.")` - V1.0 stub behavior
  - Post-launch: `SilentWolf.Scores.get_score_position(player_best_time).sw_get_position_complete` - Async SilentWolf call
- Important algorithms or logic:
  - Post-launch: caching mechanism to reduce network calls
  - Post-launch: player ranking calculation based on time comparison
- Performance considerations: No network traffic in V1.0; placeholder keeps UI responsive

## See Also
- [[technical/save-system/index]]
- [[technical/player-system]]
- [[technical/ui/index]]
- [[technical/architecture]]
