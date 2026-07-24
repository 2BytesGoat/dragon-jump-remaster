# Dragon Jump — Master Checklist

Living checklist for the refactor, release, and commercialization plan.
Updated: 2026-07-24

---

## Phase 0 — Scope Lock & Audit

- [x] Confirm product identity and V1.0 scope from `docs/direction/product_identity.md`
- [x] Confirm long-term vision from `docs/direction/vision_and_goals.md`
- [x] Lock release phases in `docs/direction/release_plan.md`
- [x] Record approved decisions in `docs/tracking/decisions.md`
- [x] Inventory autoloads and decide target roster
- [x] Inventory half-finished subsystems and decide cut/hide/keep
- [x] Create `docs/tasks/refactor_plan.md`
- [x] Create this master checklist

**Status:** Complete. V1.0 = single-button arcade speedrun, symbol-based level editor kept, AI training hidden, multiplayer/crown/progress-bar modes removed.

---

## Phase 1 — Foundation Hardening

### Code Cleanup

- [x] Rename `SceneManger` → `SceneManager` (file + autoload + all call sites)
- [x] Remove `MULTIPLAYER_LEVELS` from `Constants.gd`
- [x] Remove dead `set_multiplayer_level()` from `level.gd`
- [x] Remove `main_multiplayer` button from `main_menu` (script + scene)
- [x] Fix `emplased_time` typo → `elapsed_time` in `level.gd`
- [x] Remove unused `first_time_touching_crown` variable from `level.gd`
- [x] Audit remaining autoloads: `RuntimeSecrets`, `EnvironmentVariables`, `LeaderboardManager`, `Utils`, `Constants`, `SignalBus`
- [x] Shrink autoload roster to approved five: `SaveManager`, `SceneLoader`, `AudioManager`, `Settings`, `GameSession`
- [x] Move magic numbers / tuning values into Resource assets
- [x] Consolidate duplicated files (player controllers, level loaders, input handlers)
- [x] Standardize naming convention across files/classes/signals/groups
- [x] Make level definitions fully data-driven (`LevelData` resource + symbol parser helper)
- [x] Remove or hide remaining dead subsystems (crown/tile-tag mode remnants, progress-bar mode remnants)
- [x] Add smoke test: boot → load level → save score
- [x] Update `docs/systems/architecture.md` to reflect final structure

### Verification

- [x] Search for stale `SceneManger` / `scene_manger` references
- [x] Search for stale `MULTIPLAYER_LEVELS` references
- [x] Search for stale `main_multiplayer` references
- [x] Search for stale `emplased_time` references
- [x] Search for stale `first_time_touching_crown` references
- [x] Run Godot headless import / syntax check
- [x] Run project smoke test in editor

**Status:** Complete. Autoloads shrunk, data moved to resources, smoke test passes.

---

## Phase 2 — Arcade Vertical Slice

- [ ] Lock arcade mode design: endless vs. level-based
- [ ] Implement title → level select / endless → run → retry → local high score loop
- [ ] Wire audio, settings, transitions through approved autoloads
- [ ] Integrate hidden AI training mode via `SaveManager` only
- [ ] Add juice/polish (screenshake, SFX, clear visual language)
- [ ] Internal playtest + iteration
- [ ] Build playable arcade demo

---

## Phase 3 — Platform & Store Prep

- [ ] Pin Godot version and export templates
- [ ] Build export pipeline for Windows, Linux, macOS, Web
- [ ] Set up Steam app and store page
- [ ] Create capsule art, hero image/trailer, screenshots, tags, description
- [ ] Set price at $4.99 with 10–20% launch-week discount
- [ ] Mirror release on itch.io with DRM-free build
- [ ] Run closed beta / Steam Playtest

---

## Phase 4 — Launch & Learn

- [ ] Ship free arcade demo first
- [ ] Launch paid Steam/itch.io release
- [ ] Patch critical bugs/balance quickly
- [ ] Document learnings for next project

---

## Blockers / Open Decisions

- [x] Need final call on whether `LeaderboardManager` + `SilentWolf` stay for V1.0 or are deferred to post-launch
- [x] Need final call on whether `RuntimeSecrets` / `EnvironmentVariables` are folded into `SaveManager` or kept for AI mode only
- [ ] Need final call on gamepad support for V1.0

---

## Notes

- The `progress_bar.gd` UI component is actively used in `loading_screen`, `game_hud`, and `level_completed_overlay`. It is **not** the "progress-bar mode" mentioned in the report. The actual "progress-bar mode" (a separate game mode) has not been found in code yet and may already be gone.
- The `win_crown.gd` / `WinCrown` scene appear to be core collectables/end-goal objects, not dead code. Only the unused `first_time_touching_crown` variable was removed.
