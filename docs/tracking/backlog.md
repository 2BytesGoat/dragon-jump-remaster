---
title: Backlog
tags: [godot, game-engine, project-management, backlog, tasks]
related:
  - "[[tracking/current_sprint]]"
  - "[[tracking/decisions]]"
  - "[[direction/release_plan]]"
  - "[[backlog/shelved_features]]"
  - "[[backlog/research_ideas]]"
search_terms: [backlog, tasks, bugs, features, cleanup, known-issues]
---

# Backlog

This backlog is ordered by priority. The rule is: **foundation first, V1.0 next, post-ship features only after real player feedback.**

## Phase 0 — Foundation cleanup (before V1.0 can ship)

| # | Task | Source | Priority |
|---|------|--------|----------|
| 1 | Remove or hide unused half-implemented systems | `MULTIPLAYER_LEVELS`, crown tile, progress bar, tag-mode code | High |
| 2 | Fix `MEDAL_NAMES` typo: `SIVLER` → `SILVER` | `src/scripts/singletons/constants.gd` | High |
| 3 | Fix `unlock_next_level` off-by-one guard in `SaveManager` | `src/scripts/singletons/save_manager.gd` | High |
| 4 | Fix `last_agent_intput` typo throughout `set_jump` | `src/scenes/player/player.gd` | Medium |
| 5 | Rename `GaplingHook` / `gapling_hook.gd` to `GrapplingHook` | `src/scenes/player/gapling_hook.gd` | Medium |
| 6 | Fix `SceneManger` → `SceneManager` typo | multiple files | Medium |
| 7 | Fix `emplased_time` → `elapsed_time` typo | `src/scenes/level/level.gd` | Medium |
| 8 | Move medal threshold multipliers into `Constants` | `src/scripts/singletons/constants.gd` | Low |
| 9 | Move hardcoded default levels / agent counts into `Constants` | `main.gd`, `main_multiplayer.gd` | Low |
| 10 | Document custom synchronizer | `src/scenes/training/synchronizer.gd` | Medium |
| 11 | Document `multiplayer_world.gd` | currently untracked | Low |

## Phase 1 — V1.0 ship

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 12 | Add level `1-17` for ML workshop | Needs a symbol-based level code and balanced times | High |
| 13 | Add distinct-tiles-touched tracking | Used by RL-side for the competition | High |
| 14 | Verify end screen stats are correct | `main.gd` now hardcodes restarts/crowns; confirm this is acceptable | Medium |
| 15 | Verify main menu navigation works | Path already uses `res://`; test in build | Medium |
| 16 | Add levels for Dash, Stomp, Grapple | Currently underrepresented; depends on level design time | Medium |
| 17 | Final playtest all 16+ campaign levels | Ensure medals and unlocks feel right | High |
| 18 | Update top-level README to match V1.0 scope | Cut promises about multiplayer/editor | High |
| 19 | Set a V1.0 release deadline | Steam/itch.io for ~$5 | High |

## Phase 2 — Post-V1.0 (depends on player feedback)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 20 | Secret areas in campaign levels | Neon White-style hidden routes | TBD |
| 21 | Ghost race mode | Race your own best time / bot ghost | TBD |
| 22 | Map editor + QR-code sharing | Big feature; only if players ask for it | TBD |
| 23 | More campaign levels (target 25+) | Fill gaps for Dash, Stomp, Grapple | TBD |
| 24 | Procedural / weekly levels | Random maps for events | TBD |
| 25 | Full leaderboard integration test | SilentWolf submission flow | TBD |

## Phase 3 — Platform-specific

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 26 | Arcade mode | Limited lives, `M` tiles give extra lives, QR code to Steam | TBD |
| 27 | Steam Workshop integration | Depends on map editor existing | TBD |

## Documentation / release

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 28 | Refresh RAG / LightRAG inputs | After docs and code stabilize | Medium |

## Shelved indefinitely

See `[[backlog/shelved_features]]` for full descriptions of crown/tag, co-op, chicken-horse, and full multiplayer.