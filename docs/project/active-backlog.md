---
title: Backlog
tags: [godot, game-engine, project-management, backlog, tasks]
related:
  - "[[project/current-sprint]]"
  - "[[project/decisions]]"
  - "[[design/release-plan]]"
  - "[[future/shelved-features]]"
  - "[[future/research-ideas]]"
search_terms: [backlog, tasks, bugs, features, cleanup, known-issues]
---

# Backlog

This backlog is ordered by priority. The rule is: **ship the reproducible arcade pipeline by Aug 31, then polish the game post-deadline.**

> **Aug 31 hard deadline:** Ship a documented Godot → web → Emulation Station → Switch pipeline that jam participants can replicate. The game is the test case — it needs to be *playable enough*, not polished. See [[design/release-plan]] § Release milestones.

## Phase 1 — Hackathon prep and quick bugfixes (now)

| # | Task | Source | Priority |
|---|------|--------|----------|
| 1 | [x] Add level `1-17` for ML workshop | `Constants.LEVELS`, hidden from regular level-select, loadable by name for AI training. Layout being reimplemented. | High |
| 2 | [x] Add distinct-tiles-touched tracking | RL competition metric; see [[project/sprints/sprint-2026-07-25]] | High |
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
| 24 | [x] Grass blades | Level visual polish — shipped 2026-08-01 (grass tiles, vines, procedural grass shader) | Low |
| 25 | Glow for portal | Level visual polish | Low |
| 26 | UI texture revamp | UI visual overhaul | Medium |
| 27 | Update duplicate level | Level design cleanup | Medium |
| 28 | Make CRT effect global + add toggleable setting | Settings / visual effect | Medium |
| 29 | Player outline as toggleable setting | Settings / visual effect | Medium |
| 47 | [x] Powerup card visual system | Card art, draw animations, dissolve-on-use, pickup animations — shipped 2026-07-31 to 2026-08-01 | Medium |
| 48 | [x] Parallax background system | Clunky → polished parallax backgrounds — shipped 2026-07-28 | Medium |
| 49 | [x] In-engine level editor fixes | PR #25 merged 2026-07-27 | Medium |
| 50 | [x] Telemetry system | Local analytics autoload — shipped 2026-07-25 (see [[technical/architecture]]) | Medium |
 
## Phase 3 — Reproducible arcade pipeline (Aug 31 hard deadline)

> Goal: a documented Godot → web → Emulation Station → Switch pipeline that jam participants can replicate. The game only needs to be playable enough to prove the pipeline works. See [[design/arcade-mode]] for the full design (implementation tracked here).

### Sprint 1 — Minimal playable loop + CI verify (Aug 3 → Aug 17)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 52 | Fix arcade exit bug — mode-aware routing | `main.gd:183` `_on_exit_button_pressed()` hardcoded to level_select; arcade should go to `main_menu.tscn`, practice to `level_select.tscn` | High |
| 53 | Fix arcade "stuck at end" — no end screen shown | `main.gd:138` `_show_arcade_game_over()` is a no-op TODO; `main.gd:206` silent return on last level | High |
| 54 | Wire arcade game-over to reuse existing end_screen | Reuse `end_screen.tscn` with arcade-appropriate text (score, Try Again / Exit); no new scene, no leaderboard | High |
| 67 | Verify CI web export produces a playable HTML5 build | `.github/workflows/build-and-publish.yml` already pushes to itch via butler; verify the web artifact boots and plays in a browser (boot, arcade mode, play, die, retry, exit) | High |
| 68 | Research: can Emulation Station on the modded Switch run an HTML5 web build at all? | CFW (SX OS / Atmosphere / RetroArch), browser core / standalone HTML5 loader options. Output: a yes/no + the specific launcher mechanism. This is research only — ~1.5h. | High |
| 82 | Build scraper: fetch latest web build from itch.io and populate Emulation Station | Dev uploads to itch → scraper detects → pulls latest web build onto cabinet → ES shows it. Feasibility unknowns: itch.io API access for build downloads, where the scraper runs (on Switch? on a host? cron?), how ES discovers/launches the fetched build. Estimated ~8h for a prototype. **Depends on #68 confirming ES can run HTML5 at all.** | High |

### Sprint 2 — Emulation Station + documentation + reproducibility test (Aug 17 → Aug 31)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 69 | Install Emulation Station on the modded Switch | Document the mod setup | High |
| 70 | Configure Emulation Station to launch the web build | Browser core or standalone HTML5 loader | High |
| 71 | Test full cabinet boot flow | Power on → ES → game → play → exit → ES | High |
| 72 | Write reproducible pipeline documentation | Repo setup, CI config, export preset, ES setup, cabinet boot — so another dev can follow it | High |
| 73 | Second-dev reproducibility test | Follow only the docs, no shortcuts, replicate from scratch | High |
| 32 | Smoke-test arcade attract / game-over / restart loop | Must survive long exhibition days | High |
| 33 | Produce arcade build artifacts | Export and checksum the arcade binary | High |

### Pre-pipeline carryover (already done, kept for reference)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 30 | Final playtest all 17 campaign levels (`1-1` through `1-17`) | Ensure medals and unlocks feel right | High |
| 31 | [x] Build and verify arcade mode — logic skeleton only | Only `ArcadeDirector` logic shipped 2026-07-27/28; UI/end-flow incomplete — see #52–#54, #67–#73 | High |
| 34 | [x] Update top-level README for arcade + V1.0 scope | Cut promises about multiplayer/editor | High |

## Phase 4 — Steam release prep (deferred — after pipeline + post-September availability TBD)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 35 | Decide Steam vs arcade ordering and write it in [[project/decisions]] | Pipeline ships first; Steam is post-pipeline | High |
| 36 | Set exact V1.0 release deadline | Steam/itch.io for ~$5; TBD after September | High |
| 37 | Decide AI training mode delivery | Hidden menu vs separate build/launch flag | Medium |
| 38 | Final Steam build checklist | store page, builds, playtest branch, leaderboards | High |
| 39 | Update README to match final Steam scope | Remove arcade-only notes where irrelevant | Medium |
| 51 | Anti-piracy checklist | Started 2026-08-02 — `docs/project/anti-piracy.md` exists but incomplete (Phase 1 done; Phases 2–5 pending) | Medium |

## Phase 5 — Post-pipeline game polish (September/October, TBD)

> Deferred until after the Aug 31 pipeline milestone. Sprint-planned when September/October capacity is known. The game only needs to be "playable enough" for Aug 31; polish is a separate track.

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 55 | Arcade victory screen — clearing level 1-17 | "YOU DID IT!", final score, lives remaining, top-10 leaderboard | Medium |
| 56 | Heart pickup scene + scoring + pickup animation | `heart_pickup.tscn` + `.gd`; +1 life if <3, +500pts if full; auto-spawn in secret islands in arcade mode | Medium |
| 57 | Arcade HUD — integrate `arcade_hud.tscn` | Lives, score, level badge; draft exists at [[technical/ui/arcade-hud]] | Medium |
| 58 | Local arcade top-10 leaderboard | Extend `GameData` with `arcade_top_runs: Array`; persist via SaveManager; display on game-over/victory screens | Medium |
| 74 | Inter-level score tracking + game juice | Ensure `ArcadeDirector.score` persists across level transitions; level-finish transition animation, score popup, screen shake | Medium |
| 75 | Hidden areas in remaining 11 levels | Levels 1-4, 1-5, 1-6, 1-7, 1-10, 1-11, 1-12, 1-13, 1-14, 1-15, 1-16 need M-tiles (level design, small chunks) | Medium |
| 23 | Screen shake | Juice/polish | Medium |
| 25 | Glow for portal | Level visual polish | Low |
| 26 | UI texture revamp | UI visual overhaul | Medium |
| 27 | Update duplicate level | Level design cleanup | Medium |
| 28 | Make CRT effect global + add toggleable setting | Settings / visual effect | Medium |
| 29 | Player outline as toggleable setting | Settings / visual effect | Medium |
| 59 | SilentWolf online leaderboard integration | Plugin review; submit_arcade_score when online; offline fallback to local top-10 | Low |
| 60 | Fix telemetry — level completion time not saved | Verify `TelemetrySystem.level_finished()` persists | Low |
| 76 | Replace tileset with Nico's tiles | Needs Nico tileset format decision | Medium |
| 77 | Arcade-feeling scene transition | Replace fade-in/fade-out; needs style decision | Low |
| 78 | Bounce-pad SFX + animation | Needs sound source decision | Low |
| 79 | Menu music + SFX | Needs music source decision | Low |
| 80 | Draft new menu layout mockup | Mood board + paper/digital mockup | Low |
| 81 | Weeds on ledges | Visual polish | Low |

## Phase 6 — Post-Steam (only after real player feedback)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 40 | Secret areas in campaign levels | Neon White-style hidden routes — **pulled forward and shipped 2026-07-29** | Done |
| 41 | Ghost race mode | Race your own best time / bot ghost | TBD |
| 42 | Map editor + QR-code sharing | Big feature; only if players ask for it | TBD |
| 43 | More campaign levels (target 25+) | Fill gaps for Dash, Stomp, Grapple | TBD |
| 44 | Procedural / weekly levels | Randomly generated maps for weekly events | TBD |
| 45 | Steam Workshop integration | Depends on map editor existing | TBD |
| 46 | Full leaderboard integration test | SilentWolf submission flow | TBD |

## Open decisions (needed soon, not blocking Sprint 1)

- Switch mod setup details (SX OS, Atmosphere, RetroArch) — needed for Sprint 2 (#69–70)
- Preferred scene transition style — needed for #77 (post-pipeline)
- Bounce-pad sound source — needed for #78 (post-pipeline)
- Main menu music source — needed for #79 (post-pipeline)
- September/October capacity — decides when Phase 5 sprints happen

## Research & experiments

See [[future/research-ideas]] for RL curriculum learning, multi-level training loops, deterministic playback, and player-facing AI tools. These stay in research until Steam ships.

## Shelved indefinitely

See [[future/shelved-features]] for full descriptions of crown/tag, co-op, chicken-horse, and full multiplayer.