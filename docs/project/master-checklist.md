# Dragon Jump — Master Checklist

Living checklist for the refactor, release, and commercialization plan.
Updated: 2026-08-05

---

## Phase 0 — Scope Lock & Audit

- [x] Confirm product identity and V1.0 scope from `docs/design/product-identity.md`
- [x] Confirm long-term vision from `docs/design/vision-and-goals.md`
- [x] Lock release phases in `docs/design/release-plan.md`
- [x] Record approved decisions in `docs/project/decisions.md`
- [x] Inventory autoloads and decide target roster
- [x] Inventory half-finished subsystems and decide cut/hide/keep
- [x] Create `docs/archive/refactor-phase-1.md`
- [x] Create this master checklist

**Status:** Complete. V1.0 = editor-first speedrun platformer, EA Dec 2026 at $9.99, 1.0 Aug 2027 at $12.99 (see [[project/decisions]] 2026-08-05).

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
- [x] Update `docs/technical/architecture.md` to reflect final structure

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

> [!NOTE]
> Phase 2 is actively in progress. See [[project/sprints/sprint-2026-08-17]] for live sprint status and [[project/active-backlog]] for the full task list.
- [x] Lock arcade mode design: level-based with 3 lives, per-level checkpoints, full reset on game over (see [[design/arcade-mode]])
- [ ] Implement title → level select → run → retry → game over → local high score loop
- [ ] Wire audio, settings, transitions through approved autoloads
- [x] Integrate hidden AI training mode via `SaveManager` only (see [[design/ai-training-mode]])
- [ ] Add juice/polish (screenshake, SFX, clear visual language) — see [[project/game-juice-plan]]
- [ ] Internal playtest + iteration
- [ ] Build playable arcade demo

---

## Phase 3 — Early Access Build & Store Prep

- [ ] Pin Godot version and export templates
- [ ] Build export pipeline for Windows, Linux, macOS, Web
- [ ] Build the in-game level editor (symbol-based) — backlog #83
- [ ] Steam Workshop integration — backlog #84
- [ ] Reach 25–30 campaign levels across 5 worlds — backlog #86
- [ ] Surface ML training mode as a visible feature — backlog #90
- [ ] Set up Steam app and store page — backlog #91
- [ ] Create capsule art, hero image/trailer, screenshots, tags, description
- [ ] Set price at $9.99 for EA (12.99 at 1.0) with 20% launch discount at 1.0
- [ ] Mirror release on itch.io with DRM-free build
- [ ] Run closed beta / Steam Playtest

---

## Phase 4 — EA Launch & Learn (Dec 2026)

- [ ] Launch Early Access at $9.99
- [ ] Community management setup (bug reports, feedback, roadmap post)
- [ ] Patch critical bugs/balance quickly
- [ ] Document learnings for 1.0

---

## Phase 5 — 1.0 Launch (Aug 2027)

- [ ] 35–40 campaign levels with boss levels
- [ ] World-based arcade mode with online leaderboards
- [ ] Daily/weekly procedural challenges
- [ ] Steam leaderboards for campaign levels
- [ ] Full SFX, music, UI polish
- [ ] Launch 1.0 at $12.99 with 20% launch discount

---

## Blockers / Open Decisions

- [x] Need final call on whether `LeaderboardManager` + `SilentWolf` stay for V1.0 or are deferred to post-launch
- [x] Need final call on whether `RuntimeSecrets` / `EnvironmentVariables` are folded into `SaveManager` or kept for AI mode only
- [ ] Need final call on gamepad support for V1.0
- [ ] Daily/weekly challenge backend: SilentWolf vs. lightweight custom service
- [x] Steam Workshop technical approach — Godot Steam integration already exists and has been tested; integration is a known-quantity task (2026-08-05)
- [ ] Existing inactive Steam page: refresh in place vs. new app

---

## Notes

- There is no standalone `progress_bar.gd` UI component in the repo. Progress bars are implemented as `%LevelProgressBar` nodes inside `src/ui/screens/end_screen.tscn`. The scenes `loading_screen`, `game_hud`, and `level_completed_overlay` do not exist. This is **not** the "progress-bar mode" (a separate game mode) mentioned in the report; that mode has been cut from V1.0.
- The `win_crown.gd` / `WinCrown` scene appear to be core collectables/end-goal objects, not dead code. Only the unused `first_time_touching_crown` variable was removed.
