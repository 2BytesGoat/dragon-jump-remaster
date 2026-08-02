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
| 1 | [x] Add level `1-17` for ML workshop | `Constants.LEVELS`, hidden from regular level-select, loadable by name for AI training. Layout being reimplemented. | High |
| 2 | [x] Add distinct-tiles-touched tracking | RL competition metric; see [[tracking/sprints/sprint_2026_07_25]] | High |
| 3 | [x] Fix `MEDAL_NAMES` typo: `SIVLER` → `SILVER` | `src/scripts/singletons/constants.gd` | High |
| 4 | [x] Fix `unlock_next_level` off-by-one guard in `SaveManager` | `src/scripts/singletons/save_manager.gd` | High |
| 5 | [x] Verify end screen stats are correct | `main.gd` hardcodes restarts/crowns; confirm acceptable | Medium |
| 6 | [x] Verify main menu navigation works | Path already uses `res://`; test in build | Medium |
| 7 | [x] Check for breaking bugs in main paths | menu → level → finish → retry → next level | High |
| 8 | [x] Regression-test existing levels `1-1` through `1-16` | No crash / soft-lock / medal breakage | High |

## Phase 2 — Harden the foundation (after hackathon, before shipping)

| # | Task | Source | Priority |
|---|------|--------|----------|
| 9 | Add tutorial / input clarity for casual players | Playtest feedback: players did not know the inputs | High |
| 10 | Remove or hide unused half-implemented systems | `MULTIPLAYER_LEVELS`, crown tile, progress bar, tag-mode code | High |
| 11 | Fix `last_agent_intput` typo throughout `set_jump` | `src/scenes/player/player.gd` | Medium |
| 12 | [x] Rename `GaplingHook` / `gapling_hook.gd` to `GrapplingHook` | `src/scenes/player/grappling_hook.gd` | Medium |
| 13 | [x] Fix `SceneManger` → `SceneManager` typo | Superseded: scene navigation now uses `SceneLoader` / `scene_loader.gd` | Medium |
| 14 | [x] Fix `emplased_time` → `elapsed_time` typo | Resolved in code (variable since removed as dead) | Medium |
| 15 | [x] Fix `preogress_bar` → `progress_bar` typo in end screen | Code now uses `progress_bar` / `%LevelProgressBar` | Medium |
| 16 | [x] Rename `CampaingLevelData` → `CampaignLevelData` everywhere | `src/scripts/resources/campaign_level_data.gd` and docs | Medium |
| 17 | [x] Remove duplicated `.gd` extension from `player_ai_training_controller.gd.gd` | File is now `src/scenes/player/controller/player_ai_training_controller.gd` | Low |
| 18 | [x] Decide what to do with duplicate end screen files | `src/ui/end_screen.gd` does not exist; the only end screen is `src/ui/menus/end_screen.gd` | Low |
| 19 | Move medal threshold multipliers into `Constants` | `src/scripts/singletons/constants.gd` | Low |
| 20 | Move hardcoded default levels / agent counts into `Constants` | `main.gd` (multiplayer training scene was deleted; only arcade entry point remains) | Low |
| 21 | Document custom synchronizer | `src/scenes/training/synchronizer.gd` | Medium |
| 22 | [x] Document `multiplayer_world.gd` | File was deleted along with the multiplayer training scene; no longer needed | Low |
| 23 | Screen shake | Juice/polish | Medium |
| 24 | Grass blades | Level visual polish | Low |
| 25 | Glow for portal | Level visual polish | Low |
| 26 | UI texture revamp | UI visual overhaul | Medium |
| 27 | Update duplicate level | Level design cleanup | Medium |
| 28 | Make CRT effect global + add toggleable setting | Settings / visual effect | Medium |
| 29 | Player outline as toggleable setting | Settings / visual effect | Medium |
 
## Phase 3 — Verify all 17 levels and ship arcade (arcade is done, ship ASAP)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 30 | Final playtest all 17 campaign levels (`1-1` through `1-17`) | Ensure medals and unlocks feel right | High |
| 31 | Build and verify arcade mode | Limited lives, `M` tiles give extra lives, QR code to Steam | High |
| 32 | Smoke-test arcade attract / game-over / restart loop | Must survive long exhibition days | High |
| 33 | Produce arcade build artifacts | Export and checksum the arcade binary | High |
| 34 | [x] Update top-level README for arcade + V1.0 scope | Cut promises about multiplayer/editor | High |

## Phase 4 — Steam release prep (before any big new features)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 35 | Decide Steam vs arcade ordering and write it in [[tracking/decisions]] | Arcade ships now; Steam is next | High |
| 36 | Set exact V1.0 release deadline | Steam/itch.io for ~$5 | High |
| 37 | Decide AI training mode delivery | Hidden menu vs separate build/launch flag | Medium |
| 38 | Final Steam build checklist | store page, builds, playtest branch, leaderboards | High |
| 39 | Update README to match final Steam scope | Remove arcade-only notes where irrelevant | Medium |

## Phase 5 — Post-Steam (only after real player feedback)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 40 | Secret areas in campaign levels | Neon White-style hidden routes | TBD |
| 41 | Ghost race mode | Race your own best time / bot ghost | TBD |
| 42 | Map editor + QR-code sharing | Big feature; only if players ask for it | TBD |
| 43 | More campaign levels (target 25+) | Fill gaps for Dash, Stomp, Grapple | TBD |
| 44 | Procedural / weekly levels | Randomly generated maps for weekly events | TBD |
| 45 | Steam Workshop integration | Depends on map editor existing | TBD |
| 46 | Full leaderboard integration test | SilentWolf submission flow | TBD |

## Research & experiments

See [[backlog/research_ideas]] for RL curriculum learning, multi-level training loops, deterministic playback, and player-facing AI tools. These stay in research until Steam ships.

## Shelved indefinitely

See [[backlog/shelved_features]] for full descriptions of crown/tag, co-op, chicken-horse, and full multiplayer.