---
title: Effects System Documentation
tags: [godot, game-engine, effects, particles, animations, visual-effects]
related:
  - "[[player_system/player_system.md]]"
  - "[[level_system/level_system.md]]"
  - "[[main_system/main_system.md]]"
search_terms: [particle-effects, smoke-effects, jump-effects, background-particles, visual-effects, animation-effects, effect-system, particle-emission, animation-completion]
---

# Effects System Documentation

## Overview
- High-level description of the system's purpose: The Effects System provides various visual and audio effects used throughout the Dragon Jump Remaster game. This includes particle systems for backgrounds, smoke effects for jumps, and other visual enhancements that improve the overall gaming experience.
- Role within the overall architecture: This system enhances the visual appeal and player feedback by providing dynamic effects for gameplay events.
- Key search terms and concepts for RAG retrieval: particle-effects, smoke-effects, jump-effects, background-particles, visual-effects, animation-effects, effect-system, particle-emission, animation-completion
- System relationships and dependencies: Related to player system (player events), level system (background sizing), main system (effect management), signal bus (event communication)


## Script Components (`*.gd`)

### `background_particles.gd`
- Key properties and their purposes:
  - None specific to the component (inherits from GPUParticles2D)
- Main methods and their functionality:
  - `_ready()`: Duplicates the material to avoid affecting other instances
  - `_on_level_level_size_updated(level_size: Vector2i)`: Resizes emission box to cover full level dimensions
- Signals and connections:
  - `level_size_updated`: Triggered when level size changes, used to resize particles
- Integration points with other systems:
  - Connects to level system for level size updates
  - Uses particle materials for visual effects
  - Manages particle emission box sizing based on level dimensions
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include material duplication to prevent cross-contamination
  - Optimization hints involve dynamic resizing based on level dimensions


### `jump_smoke_effect.gd`
- Key properties and their purposes:
  - `animation_done`: Boolean flag indicating if animation has finished
  - `audio_done`: Boolean flag indicating if audio has finished
- Main methods and their functionality:
  - `_on_animation_finished()`: Sets animation_done flag and frees node if both animation and audio are done
  - `_on_audio_stream_player_2d_finished()`: Sets audio_done flag and frees node if both animation and audio are done
- Signals and connections:
  - `animation_finished`: Triggered when animation completes
  - `audio_stream_player_2d_finished`: Triggered when audio completes
- Integration points with other systems:
  - Connects to player system for jump events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- RAG metadata: performance considerations, optimization hints
  - UI flow considerations include proper cleanup after effect completion
  - Performance considerations include efficient node cleanup
  - Optimization hints involve using animation completion signals


### `despawn_smoke_effect.gd`
- Key properties and their purposes:
  - None specific to the component (inherits from AnimatedSprite2D)
- Main methods and their functionality:
  - `_on_animation_finished()`: Frees node after animation completes
  - `_on_audio_stream_player_2d_finished()`: Handles audio completion
- Signals and connections:
  - `animation_finished`: Triggered when animation completes
  - `audio_stream_player_2d_finished`: Triggered when audio completes
- Integration points with other systems:
  - Connects to player system for despawn events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include proper node cleanup
  - Optimization hints involve using animation completion signals


### `spawn_smoke_effect.gd`
- Key properties and their purposes:
  - None specific to the component (inherits from AnimatedSprite2D)
- Main methods and their functionality:
  - `_on_animation_finished()`: Frees node after animation completes
  - `_on_audio_stream_player_2d_finished()`: Handles audio completion
- Signals and connections:
  - `animation_finished`: Triggered when animation completes
  - `audio_stream_player_2d_finished`: Triggered when audio completes
- Integration points with other systems:
  - Connects to player system for spawn events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- RAG metadata: performance considerations, optimization hints
  - Performance considerations include proper node cleanup
  - Optimization hints involve using animation completion signals


## Scene Components (`*.tscn`)
### `background_particles.tscn`
- Scene hierarchy and organization:
  - GPUParticles2D node with particle settings
- Key connections between elements:
  - Connects to level system for size updates
  - Uses particle material for visual effects
- Visual layout considerations:
  - Dynamic sizing based on level dimensions
  - Background coverage effect
- RAG metadata: visual design patterns, UI flow
  - Dynamic particle systems responsive to level size


### `jump_smoke_effect.tscn`
- Scene hierarchy and organization:
  - AnimatedSprite2D node with animation settings
- Key connections between elements:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- Visual layout considerations:
  - Positioned at player location
  - Animation-based effect
- RAG metadata: visual design patterns, UI flow
  - Sprite-based animations synchronized with audio


### `despawn_smoke_effect.tscn`
- Scene hierarchy and organization:
  - AnimatedSprite2D node with animation settings
- Key connections between elements:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- Visual layout considerations:
  - Positioned at player location
  - Animation-based effect
- RAG metadata: visual design patterns, UI flow
  - Sprite-based animations synchronized with audio


### `spawn_smoke_effect.tscn`
- Scene hierarchy and organization:
  - AnimatedSprite2D node with animation settings
- Key connections between elements:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- Visual layout considerations:
  - Positioned at player location
  - Animation-based effect
- RAG metadata: visual design patterns, UI flow
  - Sprite-based animations synchronized with audio



## System Integration
- How the system interacts with other components: The Effects System connects to player system for events, level system for background sizing, and main system for effect triggering.
- Signal-based communication patterns: Uses signals from level system for size updates, animation completion signals for cleanup, and player events for effect triggering.
- Data flow and control flow:
  1. Player events occur
  2. Effect triggers are sent to effects system
  3. Visual/audio effects are played
  4. Cleanup occurs after effect completion
- Cross-system relationships for RAG linking: Related to player system (player events), level system (background sizing), main system (effect management), signal bus (event communication)


## Design Patterns
- Architecture patterns used:
  - Component pattern for visual effects
  - Observer pattern for event handling
  - Factory pattern for effect instantiation
- Code organization principles:
  - Separation of concerns between visual and audio effects
  - Modular design for different effect types
- Reusability considerations:
  - Animation-based effects can be reused across different player events
  - Particle systems can be configured for different scenarios
- Pattern-specific RAG tags and categorization:
  - component-pattern
  - observer-pattern
  - factory-pattern
  - effect-system


## Implementation Details
- Key code examples:
  - `process_material = process_material.duplicate()` - Material duplication to prevent cross-contamination
  - `mat.emission_box_extents = Vector3(half_x, half_y, 1.0)` - Dynamic particle box sizing
  - `_on_animation_finished()` - Animation completion handling for cleanup
- Important algorithms or logic:
  - Dynamic particle box resizing based on level dimensions
  - Animation and audio synchronization
  - Node cleanup after effect completion
- Performance considerations:
  - Efficient material duplication to prevent cross-contamination
  - Proper node cleanup to avoid memory leaks
  - Synchronized animation/audio for immersive experience


## See Also
- [[player_system/player_system.md]]
- [[level_system/level_system.md]]
- [[main_system/main_system.md]]
- [[signal_bus/signal_bus.md]]

