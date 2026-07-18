---
title: CampaingLevelData Resource Documentation
tags: [godot, game-engine, resource, campaign, level-data]
related:
  - "[[save_system/save_system.md]]"
  - "[[level_system/level_system.md]]"
  - "[[player_system/player_system.md]]"
search_terms: [campaign-level-data, level-resource, game-progression, level-tracking, save-system, level-code, completion-times]
---

# CampaingLevelData Resource Documentation

## Overview
- High-level description of the system's purpose: The CampaingLevelData resource is used to store information about levels within a campaign. It contains the essential properties needed to represent and track individual levels in the game's progression system.
- Role within the overall architecture: This resource serves as a data container for campaign level information, supporting save/load functionality and progress tracking.
- Key search terms and concepts for RAG retrieval: campaign-level-data, level-resource, game-progression, level-tracking, save-system, level-code, completion-times
- System relationships and dependencies: Related to save system (data persistence), level system (level generation), player system (progression tracking)

## Script Components (`*.gd`)
### `campaing_level_data.gd`
- Key properties and their purposes:
  - `name`: String - Human-readable name of the level
  - `code`: String - Symbol-based level code used for level generation  
  - `times`: Array - Array of completion times for this level
- Main methods and their functionality:
  - None (this is a resource, not a script node)
- Signals and connections:
  - None (this is a resource, not a script node)
- Integration points with other systems:
  - Used by save manager for storing and retrieving campaign level data
  - Connected to level system for level code interpretation
  - Integrates with player system for progress tracking
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include efficient data storage and retrieval
  - Optimization hints involve using appropriate data structures for time arrays

## Scene Components (`*.tscn`)
### `campaing_level_data.tscn`
- Scene hierarchy and organization:
  - This is a resource file, not a scene
- Key connections between elements:
  - None (this is a resource, not a scene)
- Visual layout considerations:
  - No visual elements required for this system
- RAG metadata: visual design patterns, UI flow
  - Not applicable for resource files

## System Integration
- How the system interacts with other components: The CampaingLevelData resource integrates with the save system for persistence, level system for code interpretation, and player system for progress tracking.
- Signal-based communication patterns: Uses signals from save manager for data loading/saving events
- Data flow and control flow:
  1. Game initializes campaign level data
  2. Save manager loads level data from storage
  3. Level system interprets level codes
  4. Player system tracks progress
- Cross-system relationships for RAG linking: Related to save system (data persistence), level system (level generation), player system (progression tracking)

## Design Patterns
- Architecture patterns used:
  - Data container pattern for structured data storage
  - Resource pattern for game data management
- Code organization principles:
  - Separation of concerns between data structure and behavior
  - Modular design for reusable level information
- Reusability considerations:
  - Can be reused across different campaign systems
  - Supports multiple level configurations
- Pattern-specific RAG tags and categorization:
  - data-container-pattern
  - resource-pattern
  - campaign-system

## Implementation Details
- Key code examples:
  - `var level_data = CampaingLevelData.new()` - Creating new level data instance
  - `level_data.name = "Level 1"` - Setting level name property
  - `level_data.times.append(time)` - Adding completion time to array
- Important algorithms or logic:
  - Data serialization for save/load operations
  - Level code interpretation from symbol-based representation
  - Time tracking and management for performance metrics
- Performance considerations:
  - Efficient data storage to minimize memory usage
  - Fast access to level properties during gameplay
  - Proper handling of time arrays for performance tracking

## See Also
- [[save_system/save_system.md]]
- [[level_system/level_system.md]]
- [[player_system/player_system.md]]

