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

The game ships as a linear sequence of campaign levels, numbered `1-1`, `1-2`, ..., `1-16` (with `1-17` planned for the ML workshop competition).

- Levels are unlocked sequentially.
- The player can replay any unlocked level at any time.
- Each level tracks attempts, best time, and medal progress.

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

- Times can be submitted to online leaderboards post-launch (SilentWolf, deferred; see [[technical/architecture]]).
- The leaderboard UI shows a "Leaderboard disabled in V1.0." placeholder; global scores are not fetched in V1.0.

See `[[technical/leaderboard]]`.

## Medals and replay value

| Medal | Goal |
|-------|------|
| Bronze | Finish the level |
| Silver | Beat a modest time threshold |
| Gold | Beat a tight time threshold |

Medals encourage replay without blocking progression.

## V1.0 scope

- 16 hand-authored campaign levels.
- Per-level save/leaderboard integration.
- Sequential unlocks.

> **Post-V1.0 ideas** (shelved): ghost race mode, arcade limited-lives mode, additional levels. See `[[future/shelved-features]]`.