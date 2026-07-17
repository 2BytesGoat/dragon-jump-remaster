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

This backlog is ordered by priority. The rule is: **fix what's blocking now, harden the foundation, ship the arcade build, then prepare Steam.**

## Phase 1 — Hackathon prep and quick bugfixes (now)

| # | Task | Source | Priority |
|---|------|--------|----------|
| 1 | Add level `1-17` for ML workshop | `Constants.LEVELS`, symbol-based level code, medal times | High |
| 2 | Add distinct-tiles-touched tracking | RL competition metric; see `[[tracking/sprints/sprint_2026_07_25]]` | High |
| 3 | Fix `MEDAL_NAMES` typo: `SIVLER` → `SILVER` | `src/scripts/singletons/constants.gd` | High |
| 4 | Fix `unlock_next_level` off-by-one guard in `SaveManager` | `src/scripts/singletons/save_manager.gd` | High |
| 5 | Verify end screen stats are correct | `main.gd` hardcodes restarts/crowns; confirm acceptable | Medium |
| 6 | Verify main menu navigation works | Path already uses `res://`; test in build | Medium |
| 7 | Check for breaking bugs in main paths | menu → level → finish → retry → next level | High |
| 8 | Regression-test existing levels `1-1` through `1-16` | No crash / soft-lock / medal breakage | High |

## Phase 2 — Harden the foundation (after hackathon, before shipping)

| # | Task | Source | Priority |
|---|------|--------|----------|
| 9 | Remove or hide unused half-implemented systems | `MULTIPLAYER_LEVELS`, crown tile, progress bar, tag-mode code | High |
| 10 | Fix `last_agent_intput` typo throughout `set_jump` | `src/scenes/player/player.gd` | Medium |
| 11 | Rename `GaplingHook` / `gapling_hook.gd` to `GrapplingHook` | `src/scenes/player/gapling_hook.gd` | Medium |
| 12 | Fix `SceneManger` → `SceneManager` typo | multiple files | Medium |
| 13 | Fix `emplased_time` → `elapsed_time` typo | `src/scenes/level/level.gd` | Medium |
| 14 | Fix `preogress_bar` → `progress_bar` typo in end screen | `src/ui/menus/end_screen.gd` | Medium |
| 15 | Rename `CampaingLevelData` → `CampaignLevelData` everywhere | `src/scripts/resources/campaing_level_data.gd` and docs | Medium |
| 16 | Remove duplicated `.gd` extension from `player_ai_training_controller.gd.gd` | `src/scenes/player/controller/player_ai_training_controller.gd.gd` | Low |
| 17 | Decide what to do with duplicate end screen files | `src/ui/end_screen.gd` vs `src/ui/menus/end_screen.gd` | Low |
| 18 | Move medal threshold multipliers into `Constants` | `src/scripts/singletons/constants.gd` | Low |
| 19 | Move hardcoded default levels / agent counts into `Constants` | `main.gd`, `main_multiplayer.gd` | Low |
| 20 | Document custom synchronizer | `src/scenes/training/synchronizer.gd` | Medium |
| 21 | Document `multiplayer_world.gd` | currently untracked | Low |

## Phase 3 — Verify all 17 levels and ship arcade (arcade is done, ship ASAP)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 22 | Final playtest all 17 campaign levels (`1-1` through `1-17`) | Ensure medals and unlocks feel right | High |
| 23 | Build and verify arcade mode | Limited lives, `M` tiles give extra lives, QR code to Steam | High |
| 24 | Smoke-test arcade attract / game-over / restart loop | Must survive long exhibition days | High |
| 25 | Produce arcade build artifacts | Export and checksum the arcade binary | High |
| 26 | Update top-level README for arcade + V1.0 scope | Cut promises about multiplayer/editor | High |

## Phase 4 — Steam release prep (before any big new features)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 27 | Decide Steam vs arcade ordering and write it in `[[tracking/decisions]]` | Arcade ships now; Steam is next | High |
| 28 | Set exact V1.0 release deadline | Steam/itch.io for ~$5 | High |
| 29 | Decide AI training mode delivery | Hidden menu vs separate build/launch flag | Medium |
| 30 | Final Steam build checklist | store page, builds, playtest branch, leaderboards | High |
| 31 | Update README to match final Steam scope | Remove arcade-only notes where irrelevant | Medium |

## Phase 5 — Post-Steam (only after real player feedback)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 32 | Secret areas in campaign levels | Neon White-style hidden routes | TBD |
| 33 | Ghost race mode | Race your own best time / bot ghost | TBD |
| 34 | Map editor + QR-code sharing | Big feature; only if players ask for it | TBD |
| 35 | More campaign levels (target 25+) | Fill gaps for Dash, Stomp, Grapple | TBD |
| 36 | Procedural / weekly levels | Randomly generated maps for weekly events | TBD |
| 37 | Steam Workshop integration | Depends on map editor existing | TBD |
| 38 | Full leaderboard integration test | SilentWolf submission flow | TBD |

## Research & experiments

See `[[backlog/research_ideas]]` for RL curriculum learning, multi-level training loops, deterministic playback, and player-facing AI tools. These stay in research until Steam ships.

## Shelved indefinitely

See `[[backlog/shelved_features]]` for full descriptions of crown/tag, co-op, chicken-horse, and full multiplayer.
