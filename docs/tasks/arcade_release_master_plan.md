---
title: Arcade Release Master Plan
tags: [planning, arcade, v1.0, tasks, polish, deployment]
related:
  - "[[direction/release_plan]]"
  - "[[direction/arcade_mode_design]]"
  - "[[level_design/level_editor_export_migration]]"
---

# Arcade Release Master Plan

This consolidates all work needed to ship the arcade vertical slice, including the user’s latest additions.

## Tracks

### Track 1 — Arcade Mode (functional loop)

Goal: playable 3-life continuous-run mode with scoring and local/online leaderboards.

From `docs/direction/arcade_mode_design.md`. Work in this order:

- [ ] Add a new arcade scene where you start from 1-1; when you finish a level, transition to the next scene in the sequence.
- [ ] Make death count up to 3; on the 3rd death, show the current progress / leaderboard menu.
- [ ] Make reset start the arcade run from 1-1 again.
- [ ] Add a new pickable scene that is the equivalent of the heart.
- [ ] Make hearts increment the player's lives up to a max of 3 when picked up.
- [ ] Extend `GameSession` with arcade fields.
- [ ] Extend `GameData` with arcade high-score persistence.
- [ ] Create `ArcadeConfig` resource (`resources/arcade_config.tres`).
- [ ] Create `ArcadeDirector` autoload.
- [ ] Modify `main.gd` for arcade run finish / game-over / continuous level transitions.
- [ ] Build `ArcadeHud` and integrate into `main.tscn`.
- [ ] Revive `LeaderboardManager` with offline fallback and arcade score support.
- [ ] Build arcade title, game-over, and victory screens.
- [ ] Apply CRT overlay / arcade theme to menus.
- [ ] Smoke test a full arcade run.

### Track 2 — Level Editor Fix

Goal: make the Godot editor a real interactive level editor.

From `docs/level_design/level_editor_export_migration.md`:

- [x] Add `@export` inspector buttons to `src/scenes/level/level.gd`:
  - `refresh_editor_preview`
  - `export_level_code_to_clipboard`
  - `export_level_code_to_level_script`
- [x] Add `force_rebuild_populated_cells()`.
- [x] Add `_export_level_code_to_level_gd()`.
- [x] Guard `_ready()` and `update_level()` for editor vs runtime.
- [x] Remove async `await` from `_get_cell_atlas_symbol()` and callers.
- [x] Fix `get_level_code()` to rebuild from TileMap layers in editor.
- [x] Fix `clear_level()` to preserve editor tiles.
- [x] Update `_init_atlas_symbol_mapping()` to reset dictionaries.
- [x] Add TMP preview resource export button.
- [x] Wire `main.gd` to load TMP preview if present.
- [x] Filter `CampaignLevelLibrary` to ignore underscore-prefixed resources.
- [ ] Test editor paint → export → clipboard / TMP preview → runtime load.

### Track 3 — Polish

Goal: make the game feel finished.

- [ ] Animated environment sprites (vines, grass) that react to player proximity.
- [ ] Replace current tileset with new tiles from Nico.
- [ ] Replace fade-in/fade-out scene transition with something more arcade-feeling.
- [ ] Add bounce-pad sound effect and animation.
- [ ] Add music and SFX to main menu / menus.
- [ ] Draft new menu layout (mood board + paper/digital mockup).
- [ ] Parallax background.
- [ ] Improved poof effect.
- [ ] Boing effect + SFX.
- [ ] Grass that reacts to the player.
- [ ] Weeds on ledges.

### Track 4 — Deployment Research

Goal: run on the modded Switch / arcade cabinet.

- [ ] Telemetry level completion time not correctly saved
- [ ] Install Emulation Station on the modded Switch.
- [ ] Identify how to launch web builds from Emulation Station (browser core, standalone HTML5 loader).
- [ ] Set up itch.io web build pipeline so games download/launch automatically.
- [ ] Document the full arcade-cabinet boot flow.

## Dependency map

| This … | depends on … |
|---|---|
| Track 1 menus / HUD | Track 3 menu layout draft + Nico tiles |
| Track 1 level transitions | Track 2 working editor (for new levels/secrets) |
| Track 3 animated tiles | Track 2 editor, because new tiles need tilemap support |
| Track 3 new transitions | Track 1 arcade flow, so we can test transitions between arcade screens |
| Track 4 deployment | Track 1 arcade build being stable enough to ship as web export |

## Suggested order

1. **Track 2 first** — the editor is a force multiplier; every other track needs levels/tiles/secrets to be editable quickly.
2. **Track 1 (core arcade loop)** in parallel with **Track 3 bounce-pad/menu audio**, since they touch different systems.
3. **Track 3 visual polish** (tiles, transitions, animated environment) once the arcade loop is playable.
4. **Track 4 deployment research** last, when there is a build worth deploying.

## Decisions needed

| Question | Owner | Status |
|---|---|---|
| Heart pickup collision: Area2D on player body layer or physical body? | Dev | Decided: Area2D on player body layer (layer 2) |
| Arcade entry scene: replace main menu or single “Practice” button? | User | Decided: arcade replaces level-select in this build |
| SilentWolf plugin status (present / missing)? | Dev | Confirmed: not in `project.godot`; implement offline-first leaderboard |
| Nico tileset format (single image, tile size, animated tiles)? | User | TODO |
| Preferred scene transition style? | User | TODO |
| Bounce-pad sound source / existing SFX? | Dev | TODO |
| Main menu music source? | User | TODO |
| Switch mod setup details (SX OS, Atmosphere, RetroArch, etc.)? | User | TODO |

## Notes / non-goals

- Do **not** add a hard deadline unless the user explicitly asks. The plan is organized by tracks and dependencies, not dates.
- The 2-player ghost placeholder is deferred post-pilot.
- Level editor export should not replace the existing runtime code path; it must live alongside it.
- Arcade mode should not break campaign save data; it uses its own `GameData` fields.

## See also

- `[[direction/arcade_mode_design]]`
- `[[level_design/level_editor_export_migration]]`
- `[[direction/release_plan]]`