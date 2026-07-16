---
title: CampaingLevelData Resource
---

# CampaingLevelData Resource

**Location**: `src/scripts/resources/campaing_level_data.gd`  
**Purpose**: Store campaign-specific level data including name, code, and completion times

## Overview
The CampaingLevelData resource is used to store information about levels within a campaign. It contains the essential properties needed to represent and track individual levels in the game's progression system.

## Properties

| Property | Type | Purpose |
|----------|------|---------|
| `name` | String | Human-readable name of the level |
| `code` | String | Symbol-based level code used for level generation |
| `times` | Array | Array of completion times for this level |

## Usage
This resource is typically used within campaign systems to track level progression and performance metrics across multiple playthroughs.

## References
- `save_manager.gd`: Used for storing and retrieving campaign level data
- `level_system.md`: Level generation and code interpretation