---
title: Secrets Layer System Documentation
tags: [godot, game-engine, level-system, secret-management, hidden-areas]
related:
  - "[[technical/level-system/index]]"
  - "[[technical/main-system]]"
search_terms: [secret-areas, hidden-tiles, flood-fill-algorithm, collision-detection, visual-hiding, secret-discovery]
---

# Secrets Layer System Documentation

This document outlines the architecture and functionality of the Secrets Layer system in the Dragon Jump Remaster project.

## Overview

The Secrets Layer system is responsible for managing hidden secret areas within game levels. It identifies connected groups of secret tiles (islands), creates collision areas for these secrets, and handles their visual hiding when discovered. The system works in conjunction with the terrain layer to provide a complete secret management solution.

## Script Components (`*.gd`)

### Key Properties and Their Purposes

| Property | Type | Purpose |
|----------|------|---------|
| `terrain_tilemap` | TileMapLayer | Reference to the main terrain tilemap for coordinate and data access |
| `visual_layer` | TileMapLayer | Reference to the visual layer for hiding secret tiles |

### Main Methods and Their Functionality

| Method | Purpose |
|--------|---------|
| `_init_secrets()` | Initializes secret areas by finding islands, generating collision areas, and hiding secret cells |
| `_hide_secret_cells(cell_array: Array)` | Hides secret cells in both terrain and visual layers, making them invisible to players |
| `_get_islands()` | Identifies connected groups of secret tiles using a flood-fill algorithm |
| `_generate_area_for_island(island: Array, island_index: int)` | Creates collision areas for each secret island with associated signals |

### Signals and Connections

| Signal | Emitted When | Purpose |
|--------|--------------|---------|
| `area_entered` | When player enters a secret area | Triggers fade-out effect for the secret layer |
| `area_exited` | When player exits a secret area | Triggers fade-in effect for the secret layer |

### Integration Points with Other Systems

- Connects to Terrain system through terrain_tilemap reference
- Works with TileMapLayer nodes for level boundary calculations
- Integrates with the main Level scene for coordinated rendering
- Uses Area2D and CollisionPolygon2D for physics-based secret detection

## Scene Components (`*.tscn`)

### Scene Hierarchy and Organization

The Secrets Layer scene is organized as follows:
1. **SecretsLayer** (TileMapLayer) - Main container for secret tiles
2. **VisualLayer** (TileMapLayer) - Visual representation layer for secrets
3. **Area2D nodes** - Dynamically created collision areas for each secret island

### Key Connections Between Elements

| Connection | Source | Target | Purpose |
|------------|--------|--------|---------|
| `area_entered` | Player collision | Secret Area2D | Triggers fade-out effect when player enters |
| `area_exited` | Player collision | Secret Area2D | Triggers fade-in effect when player exits |

### Visual Layout Considerations

The secrets layer works in conjunction with the visual layer to hide secret tiles. When a secret is discovered:
1. The secret tiles are hidden from the terrain layer
2. Visual cells corresponding to the secret area are updated
3. The entire secret island is made invisible to the player

## System Integration

### Signal-based Communication Patterns

The Secrets Layer system communicates through:
1. **Area2D collision signals** - Detects when player enters/exits secret areas
2. **Fade effects** - Uses tween animations for visual feedback
3. **Tilemap interaction** - Works with terrain tilemaps for coordinate management

### Data Flow and Control Flow

1. Level initialization calls `_init_secrets()`
2. System identifies connected secret islands using `_get_islands()`
3. For each island, creates Area2D collision area with signals
4. Hides secret cells in both terrain and visual layers
5. Player interactions trigger fade animations through signal connections

## Design Patterns

### Architecture Patterns Used

1. **Flood-Fill Pattern** - Identifies connected groups of secret tiles
2. **Observer Pattern** - Listens for area enter/exit signals from player
3. **Collision Management Pattern** - Creates and manages area-based collision detection
4. **Visual State Management** - Uses tween animations for fade effects

### Code Organization Principles

- Uses Godot's built-in signal system for collision detection
- Implements flood-fill algorithm for connected component analysis
- Leverages tilemap coordinate systems for precise placement
- Uses `@tool` annotation to allow for editor-time preview
- Maintains separation between secret management logic and visual effects

### Reusability Considerations

The Secrets Layer system is designed to be:
- Reusable across different levels with varying secret configurations
- Configurable through exported properties for different tilemap references
- Compatible with the existing scene architecture
- Extendable with additional secret types or behaviors

## Additional Notes

- The system uses a `@tool` annotation to allow for editor-time preview
- Secret islands are identified using 4-directional flood-fill algorithm
- Visual hiding is implemented by setting cells to hidden states in both layers
- Fade effects use Godot's `create_tween()` function for smooth animations
- Collision polygons are dynamically generated based on secret island boundaries