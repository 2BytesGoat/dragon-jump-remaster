---
title: Core Loop and Gameplay
tags: [godot, game-engine, gdd, gameplay, core-loop, mechanics, controls]
related:
  - "[[design/product-identity]]"
  - "[[design/progression-and-meta]]"
  - "[[technical/player-system]]"
  - "[[technical/level-system/index]]"
search_terms: [core-loop, single-button, speedrun, auto-run, jump, reset, powerups, medals]
---

# Core Loop and Gameplay

## One-sentence loop

Pick a level → run automatically → jump/reset to reach the exit → see time, medal, and rank → retry or unlock the next level.

## Editor loop

Open editor → place tiles with the symbol-based format → test the level → publish to Workshop → community plays and competes → iterate based on feedback.

> The editor is the product's core value proposition (2026-08-05 decision, [[project/decisions]]). The campaign teaches what good levels look like; the editor is where players spend most of their time.

## Controls

The game uses a **single-button** control scheme:

| Input | Action |
|-------|--------|
| Jump / action button | Jump, double-jump, dash, stomp, or grapple depending on available powerups |
| Reset button | Instantly restart the current run |
| Cancel / pause | Pause the run |

## Player movement

- The player auto-runs forward at a base speed.
- Speed can be modified by level props, powerups, or debug settings.
- All movement is physics-based in Godot 4.6.

## Powerups

Powerups are picked up from the level and consumed from a stack of up to 3:

| Symbol | Powerup | Effect |
|--------|---------|--------|
| `J` | Double Jump | Allows a second jump in mid-air |
| `D` | Dash | Horizontal burst |
| `S` | Stomp | Downward smash / ground pound |
| `G` | Grapple | Swing from a hook point |

See `[[technical/powerups]]` for implementation details.

## Level flow

1. Parse the symbol-based level code into a grid.
2. Spawn walls, hazards, powerups, secrets, and the exit portal.
3. Place the player at the `P` tile.
4. Run starts when the player presses jump.
5. Finish when the player reaches the `Q` portal.
6. Save attempts, best time, and medal progress.

## Win / fail conditions

| Condition | Result |
|-----------|--------|
| Reach exit portal | Run finishes; time submitted |
| Fall into hazard / pit | Run fails; player can instantly reset |
| Pause and restart | Run restarts without submitting |

## Medals

Each level has three time thresholds:

| Medal | Time factor |
|-------|-------------|
| Bronze | Base time × 2.5 |
| Silver | Base time × 1.65 |
| Gold | Base time × 1.2 |

> **Known issue:** The medal names array in `src/scripts/singletons/constants.gd` currently has a typo: `"SIVLER"` should be `"SILVER"`.

## Retry incentive

- Instant restart preserves muscle-memory practice.
- Best times are saved per level.
- Leaderboard integration allows global comparison.