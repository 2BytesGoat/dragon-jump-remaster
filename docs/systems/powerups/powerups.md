---
title: Powerups System Documentation
tags: [godot, game-engine, powerups, items, collectibles]
related:
  - "[[player_system]]"
  - "[[level_system]]"
  - "[[main_system]]"
search_terms: [powerups, collectibles, items, abilities, player-upgrades, jump-powerup, stomp-powerup, dash-powerup, grapple-powerup]
---

# Powerups System Documentation

## Overview
- High-level description of the system's purpose: The Powerups System provides various collectible items that grant players special abilities during gameplay. These powerups enhance the player's capabilities and add strategic depth to level completion.
- Role within the overall architecture: This system integrates with player system for ability activation, level system for powerup placement, and main system for item collection.
- Key search terms and concepts for RAG retrieval: powerups, collectibles, items, abilities, player-upgrades, jump-powerup, stomp-powerup, dash-powerup, grapple-powerup
- System relationships and dependencies: Related to player system (ability activation), level system (powerup placement), main system (game state)

## Script Components (`*.gd`)
### `powerup.gd`
- Key properties and their purposes:
  - `type`: String identifier for the type of powerup (e.g., "DoubleJump", "Stomp")
  - `color`: Color associated with this powerup type
  - `thickness`: Thickness value for visual representation
- Main methods and their functionality:
  - `_ready()`: Sets up shader material with initial color
  - `init(args: Array)`: Initializes powerup with type and color from Constants
  - `pickup()`: Handles powerup collection, disables collision and plays sound
  - `consume()`: Animates powerup consumption with visual effects
  - `reset()`: Resets powerup state for reuse
  - `_on_animation_ended()`: Triggers reset when animation completes
- Signals and connections:
  - Connects to player collision detection
  - Uses Constants for powerup color definitions
  - Integrates with audio system for sound effects
  - Uses shader materials for visual effects
- Integration points with other systems:
  - Connects to player system for collision detection
  - Uses Constants for powerup color definitions
  - Integrates with audio system for sound effects
  - Uses shader materials for visual effects
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include efficient collision handling
  - Optimization hints involve using deferred calls for disabling collisions

### `card_scene.gd`
- Key properties and their purposes:
  - `is_splitscreen`: Boolean indicating if game is in split-screen mode
  - `powerup_type`: String identifier for the displayed powerup type
  - `scales`: Dictionary containing scaling values for single player vs split screen modes
  - `y_scale`: Vertical scale factor for positioning
  - `container_scale`: Scale factor for the container
- Main methods and their functionality:
  - `_ready()`: Sets up scaling based on game mode
  - `draw(type: String, exists: bool = false)`: Displays powerup with appropriate animation
  - `shift_by(offsets: Array)`: Adjusts container margins by specified offsets
  - `play_draw_new_animation()`: Plays animation for new powerup acquisition
  - `play_draw_same_animation()`: Plays animation for already acquired powerup
- Signals and connections:
  - Uses Constants for powerup color definitions
  - Integrates with UI system for display
  - Uses AnimationPlayer for visual effects
  - Implements tween animations for smooth transitions
- Integration points with other systems:
  - Uses Constants for powerup color definitions
  - Integrates with UI system for display
  - Uses AnimationPlayer for visual effects
  - Implements tween animations for smooth transitions
- RAG metadata: performance considerations, optimization hints
  - UI flow considerations include smooth animations and proper positioning in different game modes

## Scene Components (`*.tscn`)
### `powerup.tscn`
- Scene hierarchy and organization:
  - Area2D node containing AnimatedSprite2D, AudioStreamPlayer, CollisionShape2D, and AnimationPlayer
- Key connections between elements:
  - Connects to player collision detection
  - Uses AudioStreamPlayer for sound effects
  - Integrates with AnimationPlayer for visual effects
- Visual layout considerations:
  - Animated sprite for powerup appearance
  - Collision shape for collection detection
- RAG metadata: visual design patterns, UI flow
  - Visual design patterns include animated sprites, audio feedback, and collision detection

### `card_scene.tscn`
- Scene hierarchy and organization:
  - Control node containing MarginContainer with TextureRect and Label
- Key connections between elements:
  - Connects to UI system for display
  - Uses AnimationPlayer for visual effects
  - Implements tween animations for smooth transitions
- Visual layout considerations:
  - Responsive design for different game modes (single player vs split screen)
  - Color-coded powerup indicators
- RAG metadata: visual design patterns, UI flow
  - Visual design patterns include responsive UI elements, animated transitions

## System Integration
- How the system interacts with other components: Powerups system connects to player system for collection events, level system for placement, and main system for game state management
- Signal-based communication patterns: Uses collision detection signals, animation completion signals
- Data flow and control flow: Level generation → Powerup placement → Player collection → Ability activation → UI update
- Cross-system relationships for RAG linking: Related to player system (ability activation), level system (powerup placement), main system (game state)

## Design Patterns
- Architecture patterns used:
  - Component pattern for powerup items
  - Observer pattern for event handling
- Code organization principles:
  - Separation of concerns between visual representation and game logic
- Reusability considerations:
  - Powerup class can be reused with different types
  - Card UI component handles multiple powerup types
- Pattern-specific RAG tags and categorization:
  - component-pattern
  - observer-pattern
  - powerup-system

## Implementation Details
- Key code examples:
  - `sprite.material.set_shader_parameter("replace_0", color)` - Shader parameter setting for visual effects
  - `create_tween()` - Animation creation for smooth UI transitions
  - `call_deferred("set_disabled", true)` - Deferred collision disabling for performance
- Important algorithms or logic:
  - Powerup type and color initialization from Constants
  - Animation-based visual feedback for collection events
  - Scale adjustment for different game modes
- Performance considerations:
  - Efficient collision handling
  - Deferred calls for UI updates
  - Smooth animations

## See Also
- [[systems/player_system/player_system.md]]
- [[systems/level_system/level_system.md]]
- [[systems/main_system/main_system.md]]
