---
title: Progression and Meta
tags: [godot, game-engine, gdd, progression, meta, save-system, unlocks, leaderboards]
related:
  - "[[design/core-loop]]"
  - "[[design/release-plan]]"
  - "[[technical/save-system/index]]"
  - "[[technical/leaderboard]]"
search_terms: [progression, unlocks, medals, save, leaderboard, campaign, level-select]
---

# Progression and Meta

## Campaign structure

The game ships with 35–40 handcrafted levels across 5 themed worlds. Each world has 6–8 regular levels and 1 boss level. The EA build ships 25–30 of these; the remaining levels land by 1.0. (Current levels 1-1 through 1-17 are being reorganized into this world structure.)

- Worlds unlock sequentially (beat world N to unlock world N+1).
- Levels within a world unlock sequentially.
- The player can replay any unlocked level at any time.
- Each level tracks attempts, best time, and medal progress.
- Boss levels test mastery of all mechanics from that world — longer, harder, no powerup pickups inside.

## Arcade structure

- Pick a world → play all its levels with 3 lives → score submitted to the world leaderboard.
- Hidden extra lives behind `M` secret tiles.
- "Gauntlet" mode unlocks after all worlds cleared (all worlds back-to-back, 5 lives).
- World-based arcade with online leaderboards (SilentWolf) ships at 1.0; EA has a basic arcade with a local top-10.

## Save data

Per level, the save file stores:

| Field | Purpose |
|-------|---------|
| `attempts` | Total number of restart/run attempts |
| `best_time` | Fastest successful completion time |
| `progress_milestone` | Highest medal milestone reached |
| `progress_percentage` | Progress toward the next milestone |

See `[[technical/save-system/index]]` and `[[technical/save-system/level-data]]` for implementation details.

## Level select

- The level select screen shows all unlocked levels.
- Each level button displays best time and medal status.
- Locked levels are visually distinct until unlocked.

## Leaderboards

- Campaign levels: permanent per-level best times on Steam leaderboards (1.0).
- Daily/weekly challenges and arcade: SilentWolf leaderboards (time-windowed, no manual clearing needed).
- The EA leaderboard UI shows a "Leaderboards arriving at 1.0." placeholder until the 1.0 backend lands.

See `[[technical/leaderboard]]`.

## Medals and replay value

| Medal | Goal |
|-------|------|
| Bronze | Finish the level |
| Silver | Beat a modest time threshold |
| Gold | Beat a tight time threshold |

Medals encourage replay without blocking progression.

## V1.0 scope

- 35–40 handcrafted campaign levels across 5 worlds (25–30 at EA).
- World-based arcade mode with boss levels and world leaderboards.
- Daily/weekly procedural challenges.
- Per-level save/leaderboard integration.
- Sequential world unlocks.

> **Post-1.0 ideas** (shelved): ghost race mode, endless procedural mode, additional levels. See `[[future/shelved-features]]`.