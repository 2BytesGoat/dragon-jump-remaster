---
title: Player System Documentation
tags: [godot, game-engine, player-system, character-controller, state-machine]
related:
  - "[[technical/main-system]]"
  - "[[technical/level-system/index]]"
  - "[[technical/save-system/index]]"
search_terms: [player-character, character-controller, state-machine, physics-movement, power-ups, grappling-hook]
---

# Player System Documentation

This document outlines the architecture and functionality of the Player system in the Dragon Jump Remaster project.

## Overview

The Player system represents the main character in the game, handling movement, physics, state management, and interactions with game elements. It uses a state machine pattern to manage different player states such as idle, moving, jumping, falling, and wall sliding.

## Script Components (`*.gd`)

### Key Properties and Their Purposes

| Property | Type | Purpose |
|----------|------|---------|
| `controller_type` | CONTROLLERS | Determines which controller is active (PLAYER_ONE, PLAYER_TWO, TRAINING) |
| `starting_facing_direction` | int | Initial facing direction of the player (RIGHT.x or LEFT.x) |
| `default_max_speed` | float | Base maximum movement speed |
| `default_acceleration` | float | Base acceleration rate |
| `jump_height` | float | Height the player can jump |
| `default_jump_time_to_peak` | float | Time to reach jump peak |
| `jump_time_to_peak` | float | Actual time to reach jump peak (affected by speed modifier) |
| `state_machine` | StateMachine | Reference to the state machine managing player states |
| `active_controller` | PlayerCharacterController | Currently active controller |
| `flippable_container` | Node2D | Container for sprite that handles flipping |
| `animation_player` | AnimationPlayer | Handles player animations |
| `grappling_hook` | Node2D | Reference to grappling hook system |
| `hat_container` | Node2D | Container for player accessories like hats/crowns |
| `has_crown` | bool | Whether the player currently has a crown |
| `powerups` | Array | List of active power-ups |
| `level_reference` | Level | Reference to the current level |

### Main Methods and Their Functionality

| Method | Purpose |
|--------|---------|
| `_ready()` | Initializes player settings and calls reset |
| `_physics_process(delta)` | Handles physics-based movement calculations |
| `set_controller(controller)` | Sets the active controller for the player |
| `set_jump(input)` | Processes jump input from controllers |
| `reset()` | Resets player to starting position and state |
| `add_modifier(modifier_name, modifier_value)` | Adds temporary gameplay modifiers |
| `remove_modifier(modifier_name)` | Removes a gameplay modifier |
| `play_animation(animation_name)` | Plays specified animation |
| `pick_powerup(area)` | Handles power-up collection |
| `has_powerups()` | Checks if player has any active power-ups |
| `consume_powerup()` | Uses up one power-up |
| `launch_grappling_hook()` | Activates grappling hook |
| `release_grappling_hook()` | Releases grappling hook |
| `drop_crown()` | Drops the crown if player has one |

### Signals and Connections

| Signal | Emitted When | Purpose |
|--------|--------------|---------|
| `picked_powerup` | When player collects a power-up | Notifies systems of power-up collection |
| `used_powerup` | When player uses a power-up | Notifies systems of power-up usage |
| `has_resetted` | After player reset | Notifies systems of player reset |

### Integration Points with Other Systems

- Connects to `StateMachine` for state management
- Interacts with `Level` system through `level_reference`
- Communicates with `SignalBus` for game events
- Integrates with `Powerup` system via collision detection
- Works with `SaveManager` for saving player state
- Uses `Utils` for scene instantiation

## Scene Components (`*.tscn`)

### Scene Hierarchy and Organization

The Player scene is organized as follows:
1. **Player** (CharacterBody2D) - Main node with physics properties
2. **Flippable** (Node2D) - Container for sprite that handles flipping
   - **Sprite** (Sprite2D) - Visual representation of player
   - **HatContainer** (Node2D) - Container for accessories like crowns
   - **AfterImage** (CPUParticles2D) - Visual effect for movement trails
   - **GrapplingHook** (Node2D) - Grappling hook system
     - **GrapplingPoints** (Node2D) - Points for grappling hook
     - **RayCast2D** - Raycast for detecting hook targets
     - **GrappleIndicator** (Sprite2D) - Visual indicator for hook
     - **Line2D** - Line showing connection between player and hook
3. **CollisionShape2D** (CollisionShape2D) - Physics collision shape
4. **InteractBox** (Area2D) - Detection area for power-ups and interactions
5. **HurtBox** (Area2D) - Collision area for damage sources
6. **ControllerContainer** (Node) - Container for controllers
7. **StateMachine** (Node) - Manages player states with child nodes:
   - **Idle**, **Move**, **Fall**, **Jump**, **Walled**, **DoubleJump**, **Stomp**, **Dash**, **Grapple**, **Bounce**
8. **AnimationPlayer** (AnimationPlayer) - Handles player animations
9. **StateLabel** (Label) - Debug label showing current state

### Key Connections Between Elements

| Connection | Source | Target | Purpose |
|------------|--------|--------|---------|
| `should_release` | GrapplingHook | Grapple State | Handles grappling hook release |
| `area_entered` | InteractBox | Player | Detects power-up and interaction areas |
| `area_exited` | InteractBox | Player | Handles exit from interaction areas |
| `body_entered` | InteractBox | Player | Handles collision with interactive objects |
| `body_entered` | HurtBox | Player | Handles collision with damage sources |
| `transitioned` | StateMachine | StateLabel | Updates debug display of current state |

### Visual Layout Considerations

The player scene uses a layered approach:
- **Sprite** - Main visual representation with frame animation
- **HatContainer** - For accessories like crowns that can be added/removed
- **AfterImage** - Particle effect for movement trails when enabled
- **GrapplingHook** - Interactive grappling hook system with raycast detection
- **StateLabel** - Debug overlay showing current player state

## System Integration

### Signal-based Communication Patterns

The Player system communicates through:
1. **SignalBus** - For global events like player finished run, player restarted run
2. **Area2D collision** - For power-up collection and interaction detection
3. **State machine transitions** - For internal state changes and communication with states

### Data Flow and Control Flow

1. Input from controllers is processed through `set_jump()` method
2. Physics calculations happen in `_physics_process()`
3. State transitions occur via the StateMachine system
4. Power-ups are collected through collision detection and handled by `pick_powerup()`
5. Player state is reset via `reset()` method

## Design Patterns

### Architecture Patterns Used

1. **State Machine Pattern** - Used for managing player states like idle, move, jump, fall, etc.
2. **Controller Pattern** - Supports different controller types (player one, two, training)
3. **Component Pattern** - Separates concerns into collision detection, animation, physics, etc.

### Code Organization Principles

- Uses `@onready` for node references to ensure proper initialization
- Leverages Godot's built-in signal system for communication
- Implements a modular design with clear separation of concerns
- Uses property setters for automatic updates when values change

### Reusability Considerations

The Player system is designed to be:
- Reusable across different game modes (single-player, multiplayer)
- Configurable through exported properties
- Extendable with new controller types
- Compatible with the existing state machine architecture

## Additional Notes

- The player uses a custom physics implementation with separate jump and fall gravity calculations
- Supports multiple power-ups with a maximum of 3 active at once
- Includes grappling hook functionality with visual indicators
- Has a state label for debugging purposes (visible in debug mode)
- Implements proper reset functionality for game progression