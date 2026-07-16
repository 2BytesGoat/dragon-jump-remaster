---
title: Effects System Documentation
tags: [godot, game-engine, effects, particles, animations]
related: [[player_system/player_system.md]], [[level_system/level_system.md]]
search_terms: [particle-effects, smoke-effects, jump-effects, background-particles, visual-effects, animation-effects]
---

# Effects System Documentation

## Overview
The Effects System provides various visual and audio effects used throughout the Dragon Jump Remaster game. This includes particle systems for backgrounds, smoke effects for jumps, and other visual enhancements that improve the overall gaming experience.

Key search terms and concepts for RAG retrieval: particle-effects, smoke-effects, jump-effects, background-particles, visual-effects, animation-effects
System relationships and dependencies: This system integrates with player system for jump effects, level system for background particles, and main system for effect triggering.

## Script Components (`*.gd`)

### `background_particles.gd`
- **Purpose**: Manages particle effects that cover the background of levels, dynamically resizing to fit level dimensions
- **Key properties**:
  - None specific to the component (inherits from GPUParticles2D)
- **Main methods**:
  - `_ready()`: Duplicates the material to avoid affecting other instances
  - `_on_level_level_size_updated(level_size: Vector2i)`: Resizes emission box to cover full level dimensions
- **Signals**:
  - `level_size_updated`: Triggered when level size changes, used to resize particles
- **Integration points with other systems**:
  - Connects to level system for level size updates
  - Uses particle materials for visual effects
  - Manages particle emission box sizing based on level dimensions
- **RAG metadata**: Performance considerations include material duplication to prevent cross-contamination, optimization hints involve dynamic resizing based on level dimensions

### `jump_smoke_effect.gd`
- **Purpose**: Handles smoke animation and audio effects when a player jumps
- **Key properties**:
  - `animation_done`: Boolean flag indicating if animation has finished
  - `audio_done`: Boolean flag indicating if audio has finished
- **Main methods**:
  - `_on_animation_finished()`: Sets animation_done flag and frees node if both animation and audio are done
  - `_on_audio_stream_player_2d_finished()`: Sets audio_done flag and frees node if both animation and audio are done
- **Integration points with other systems**:
  - Connects to player system for jump events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- **RAG metadata**: UI flow considerations include proper cleanup after effect completion

### `despawn_smoke_effect.gd`
- **Purpose**: Handles smoke effects when a player despawns or dies
- **Key properties**:
  - None specific to the component (inherits from AnimatedSprite2D)
- **Main methods**:
  - `_on_animation_finished()`: Frees node after animation completes
  - `_on_audio_stream_player_2d_finished()`: Handles audio completion
- **Integration points with other systems**:
  - Connects to player system for despawn events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- **RAG metadata**: Performance considerations include proper node cleanup, optimization hints involve using animation completion signals

### `spawn_smoke_effect.gd`
- **Purpose**: Handles smoke effects when a player spawns or respawns
- **Key properties**:
  - None specific to the component (inherits from AnimatedSprite2D)
- **Main methods**:
  - `_on_animation_finished()`: Frees node after animation completes
  - `_on_audio_stream_player_2d_finished()`: Handles audio completion
- **Integration points with other systems**:
  - Connects to player system for spawn events
  - Uses AnimatedSprite2D for visual effects
  - Integrates with audio system for sound effects
- **RAG metadata**: Performance considerations include proper node cleanup, optimization hints involve using animation completion signals

## Scene Components (`*.tscn`)
### `background_particles.tscn`
- **Scene hierarchy and organization**: GPUParticles2D node with particle settings
- **Key connections between elements**:
  - Connects to level system for size updates
  - Uses particle material for visual effects
- **Visual layout considerations**: 
  - Dynamic sizing based on level dimensions
  - Background coverage effect
- **RAG metadata**: Visual design patterns include dynamic particle systems, responsive to level size

### `jump_smoke_effect.tscn`
- **Scene hierarchy and organization**: AnimatedSprite2D node with animation settings
- **Key connections between elements**:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- **Visual layout considerations**:
  - Positioned at player location
  - Animation-based effect
- **RAG metadata**: Visual design patterns include sprite-based animations, synchronized with audio

### `despawn_smoke_effect.tscn`
- **Scene hierarchy and organization**: AnimatedSprite2D node with animation settings
- **Key connections between elements**:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- **RAG metadata**: Visual design patterns include sprite-based animations, synchronized with audio

### `spawn_smoke_effect.tscn`
- **Scene hierarchy and organization**: AnimatedSprite2D node with animation settings
- **Key connections between elements**:
  - Connects to audio stream player for sound effects
  - Uses animation player for visual effects
- **RAG metadata**: Visual design patterns include sprite-based animations, synchronized with audio

## System Integration
- How the system interacts with other components: Effects system connects to player system for events, level system for background sizing, and main system for effect triggering
- Signal-based communication patterns: Uses signals from level system for size updates, animation completion signals for cleanup
- Data flow and control flow: Player events → Effect triggers → Visual/audio effects → Cleanup
- Cross-system relationships for RAG linking: Related to player system (player events), level system (background sizing), main system (effect management)

## Design Patterns
- Architecture patterns used: Component pattern for visual effects, Observer pattern for event handling
- Code organization principles: Separation of concerns between visual and audio effects
- Reusability considerations: Animation-based effects can be reused across different player events
- Pattern-specific RAG tags and categorization: component-pattern, observer-pattern, effect-system

## Implementation Details
- Key code examples:
  - `process_material = process_material.duplicate()` - Material duplication to prevent cross-contamination
  - `mat.emission_box_extents = Vector3(half_x, half_y, 1.0)` - Dynamic particle box sizing
  - `_on_animation_finished()` - Animation completion handling for cleanup
- Important algorithms or logic: 
  - Dynamic particle box resizing based on level dimensions
  - Animation and audio synchronization
  - Node cleanup after effect completion
- Performance considerations: Efficient material duplication, proper node cleanup, synchronized animation/audio

## See Also
- [[player_system/player_system.md]]
- [[level_system/level_system.md]]