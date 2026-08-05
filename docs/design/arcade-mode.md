---
title: Arcade Mode Design
tags: [arcade, v1.0, design, lives, secrets, leaderboard, menus]
related:
  - "[[design/release-plan]]"
  - "[[design/product-identity]]"
  - "[[design/core-loop]]"
  - "[[future/shelved-features]]"
  - "[[technical/ui/arcade-hud]]"
---

# Arcade Mode Design — Dragon Jump Remaster

> **Implementation is tracked in [[project/active-backlog]]** (Phase 3 — reproducible arcade pipeline, Phase 5 — post-pipeline game polish). This document is the design reference for how arcade mode should feel and behave.

## Goal

Ship a vertical-slice arcade build that is simple to understand and hard to master:
- One button to jump/act.
- One mode: a continuous campaign run.
- 3 lives, hidden extra lives, per-level checkpoint, full reset on game over.
- Score tracks progress; leaderboard tracks best arcade runs.

This replaces the campaign/level-select flow in the arcade/free build. The Steam paid build may re-introduce level-select practice later.

## Core loop

Title screen → Press start → Level 1-1 → reach exit → auto-teleport to 1-2 → … → die 3 times → Game Over → full restart from 1-1.

### Lives and death

- Player starts with **3 lives**.
- Each death removes **1 life** and respawns the player at the **start of the current level** with the **current level’s powerups reset** (powerups do not carry between levels).
- When lives reach **0**, the run ends and the player returns to the **title screen** (or a game-over screen).
- The player must start the arcade run from **1-1** again.

### Hidden rewards

- Secret areas use the existing `M` secret tile.
- Every secret island automatically spawns a **heart pickup**.
- Collecting a heart restores **1 life**, up to the **3-life maximum**.
- If the player is already at 3 lives, the heart awards **+100 points** instead.

### Scoring

| Source | Value |
|---|---|
| Each level cleared | +1,000 points |
| Each life remaining at game over | +500 points |
| Each heart picked up while at full health | +100 points |
| Time bonus | TBD (optional, post-pilot) |

- Final score is shown on the game-over screen.

### Manual reset in arcade mode

- In **Practice** mode the reset button is free, because the goal is learning the level.
- In **Arcade** mode a manual reset is treated as a deliberate “do-over” and costs **1 life**, the same as a death. The player respawns at the current level start with powerups reset.
- Rationale: arcade runs are limited to 3 lives. If a reset were free, players could repeatedly restart to chase perfect execution without consuming the run’s core resource, which undermines the arcade stakes. By making reset and death share the same cost, the 3 lives stay meaningful and secret heart pickups remain valuable.

### Balancing reset against scoring

Because a reset trades **1 life = 500 end-of-run points**, the scoring system must reward faster clears enough that a reset can be worth it:

- **Time bonus per level** should decay from a maximum down to zero as level clear time increases.
- A reset should be expected to pay for itself when the new clear time is meaningfully faster than the player’s previous attempt (e.g., below a target percentile of the level’s average completion time).
- Rough tuning target:
  - `max_time_bonus_per_level` should be **≥ 2× life_remaining_score** so that one successful re-try can compensate the lost life.
  - `time_bonus_decay` should be tuned so that an average clear time earns roughly `1× life_remaining_score`, making a “good” clear profitable and a sloppy clear break-even or worse.

Concrete draft formula:

```gdscript
time_bonus = max(0, max_time_bonus_per_level - floor(level_clear_time * time_bonus_decay_per_second))
```

- Example: `max_time_bonus_per_level = 1000`, `time_bonus_decay_per_second = 100`.
  - 5s clear → 500 bonus.
  - 10s clear → 0 bonus.
  - Resetting costs 500 end-of-run points, so a 5s re-clear is break-even on the life trade and still gains the base 1,000 level-clear points.

> This is a design placeholder. Exact values require play-testing and per-level target times.

- Highest score is saved locally.
- Online submission via SilentWolf when internet is available (deferred to post-launch; see [[technical/architecture]]).

### Continuous level transition

- On reaching the exit portal, the game does **not** show the existing end-screen.
- `ArcadeDirector` loads the next level in sequence using `CampaignLevelLibrary.get_next_level()`.
- The player is teleported to the new start point.
- Powerups are cleared and the level is spawned fresh.
- If the last level is cleared, show a victory screen with final score.

## New and changed components

### Data

- `resources/arcade_config.tres` — tunable values:
  - `starting_lives = 3`
  - `max_lives = 3`
  - `level_clear_score = 1000`
  - `life_remaining_score = 500`
  - `overheal_score = 100`
- Extend `GameSession` with:
  - `is_arcade_mode: bool`
  - `arcade_lives: int`
  - `arcade_score: int`
  - `arcade_levels_completed: int`
  - `arcade_current_level_index: int`
- Extend `GameData` with:
  - `arcade_high_score: int`
  - `arcade_best_levels: int`
  - `arcade_top_runs: Array[ArcadeRunData]` (player_name, score, levels, date)

### New scenes/scripts

- `src/scenes/level/tiles/heart_pickup.tscn` + `heart_pickup.gd`
- `src/scripts/singletons/arcade_director.gd` — autoload, manages arcade run state and level transitions
- `src/ui/components/arcade_hud.tscn` + `arcade_hud.gd` — HUD from existing draft
- `src/ui/menus/arcade_title_screen.tscn` + `arcade_title_screen.gd`
- `src/ui/menus/arcade_game_over_screen.tscn` + `arcade_game_over_screen.gd`
- `src/ui/menus/arcade_victory_screen.tscn` + `arcade_victory_screen.gd`

### Modified scenes/scripts

- `main.gd`:
  - Branch run finish behavior based on `GameSession.is_arcade_mode`.
  - Arcade: advance to next level instead of showing end screen.
  - Handle `arcade_life_lost` and `arcade_game_over`.
  - In arcade mode, treat the manual reset button as a life loss (same cost as death) and respawn the player at the current level start.
- `Level.gd`:
  - Auto-spawn heart pickups at the center of each secret island in `_init_hidden_areas()` when `GameSession.is_arcade_mode` is true.
  - Or add a new `H` symbol and place hearts manually. Default to auto-spawn for the pilot.
- `main.tscn`:
  - Replace `TimeContainer` + `CardContainerContainer` with `ArcadeHud`.
  - Keep `PauseScreen`, `EndScreen` hidden in arcade mode.

### Leaderboard (post-launch)

- `LeaderboardManager` (post-launch):
  - Keep SilentWolf submission path for online leaderboards.
  - Add a local cache path that works offline.
  - Expose `submit_arcade_score(player_name, score, levels)` and `get_arcade_leaderboard()`.
- `Leaderboard` UI:
  - Reuse for both per-level and arcade high scores.
  - Arcade mode shows: rank, player name, score, levels completed.

## Menu revamp direction

### Visual pillars

- Black background + neon/candy colors from existing sprite palette.
- Full-screen CRT scanline/curve shader (`assets/shaders/screen_crt.gdshader`).
- Big chunky `PressStart2P-Regular.ttf` labels.
- Bezel panels: `StyleBoxFlat` dark fill + bright 2 px border.
- Pulsing “PRESS JUMP TO START” on title screen.
- Focused button has glow/scale tween.

### Screens

1. **Arcade Title Screen**
   - Game logo
   - Pulsing “PRESS JUMP TO START”
   - Local high-score ticker at the bottom
2. **Arcade HUD (in-game)**
   - Top bar: level badge left, big timer center, lives as hearts right
   - Bottom bar: 3 fixed powerup slots
3. **Pause Screen**
   - Resume / Restart Run / Exit to Title
4. **Game Over Screen**
   - “GAME OVER”
   - Final score, levels completed
   - New high score indicator
   - Local top 5 list
   - “TRY AGAIN” / “EXIT”
5. **Victory Screen**
   - “YOU DID IT!”
   - Final score, lives remaining
   - Local top 5 list

### Open question: 2-player / ghost placeholder

- **Deferred to post-pilot.**
- The cabinet is 2-player, but the first arcade slice ships as a single-player run.
- Later: a toggle to show a second ghost player as a placeholder opponent, using existing ghost playback.

## Implementation order

1. Create `ArcadeConfig` resource and add to `Constants`.
2. Extend `GameSession` and `GameData` with arcade fields.
3. Create heart pickup scene and auto-spawn in secret islands.
4. Create `ArcadeDirector` autoload.
5. Modify `main.gd` for arcade run finish / game-over flow.
6. Build `ArcadeHud` and integrate into `main.tscn`.
7. Revive `LeaderboardManager` with offline fallback and arcade support.
8. Build arcade title, game-over, and victory screens.
9. Apply CRT overlay and theme to all arcade menus.
10. Smoke test a full arcade run and verify persistence.

## Decisions log

| Decision | Rationale |
|---|---|
| Arcade mode replaces level-select in this build | Simpler menu, fits exhibition/free vertical slice, matches “continuous climb” genre feel |
| 3 lives, per-level checkpoint, full reset on game over | Arcade tension without being unfair; mirrors games like Jump King |
| Powerups reset each level | Keeps level balance consistent; no snowballing |
| Hearts auto-spawn in every secret island | Fastest way to guarantee rewards; no level editing required |
| Hearts over-heal convert to +100 points | Keeps secrets valuable at full health |
| SilentWolf leaderboard + local fallback | Online for v1 leaderboards, local cache for offline arcade cabinets |
| Ghost/2-player deferred | Scope control; can reuse existing ghost playback later |
| Manual reset costs 1 life in arcade mode | Aligns reset with death semantics; protects the 3-life arcade tension and keeps secret heart pickups valuable |

## See also

- `[[design/release-plan]]`
- `[[design/core-loop]]`
- `[[future/shelved-features]]`
- `[[technical/ui/arcade-hud]]`