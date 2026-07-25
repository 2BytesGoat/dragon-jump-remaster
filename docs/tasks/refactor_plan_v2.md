# Refactor Plan v2 — Dragon Jump Remaster

Post-audit execution plan. Each task is scoped to a single focused session and can be handed to a freelancer or completed end-to-end by one developer.

---

## Phase 2.1 — Secure Save/Load & Anti-Cheat

- [x] Replace plain `.tres` save format with encrypted binary or JSON + HMAC checksum
  - File: `src/scripts/singletons/save_manager.gd`
  - Keep `GameData` as the in-memory schema; serialize to `user://%s_savegame.bin`
  - Add `save_version` field to `GameData` and migration helpers
- [x] Validate save data on load; fall back to a fresh save on corruption/tampering/missing keys
  - File: `src/scripts/singletons/save_manager.gd`
  - Never crash on a missing level key
- [x] Split settings from progress data so settings can be saved cheaply and independently
  - File: `src/scripts/resources/game_data.gd` and `src/scripts/singletons/settings.gd`
  - Introduce a typed `SettingsData` Resource
- [x] Add save/load smoke tests covering tampered and outdated save files
  - File: `src/tests/test_save_score.gd` and new `src/tests/test_save_security.gd`

---

## Phase 2.2 — Stabilize Player Physics & State Machine

- [x] Refactor `Player._physics_process` so velocity integration happens exactly once per frame
  - File: `src/scenes/player/player.gd`
  - `StateMachine.manual_physics_process` is enabled; `Player` calls `state_machine.step_physics(delta)` before applying gravity/horizontal accel and calling `move_and_slide()` once
  - Removed the global velocity integration from running before state logic
- [x] Fix state name mismatch: rename `Swing` class to `Grapple` to match the `Grapple` state node
  - File: `src/scenes/player/player.tscn` and `src/scenes/player/states/grapple_state.gd` (renamed from `swing_state.gd`)
  - Powerup type string "Grapple" already routes to the matching node name
- [x] Replace state-name-based `on_floor()` with `CharacterBody2D.is_on_floor()`
  - File: `src/scenes/player/player.gd`
  - `on_floor()` now returns `is_on_floor()`; `on_wall()` returns `is_on_wall()`
- [x] Extract bounce/dash multipliers from magic numbers into `PhysicsParams`
  - File: `src/scenes/player/states/bounce_state.gd`, `src/scenes/player/states/dash_state.gd`
  - Added exported fields to `src/scripts/resources/physics_params.gd` and values to `resources/physics_params.tres`
- [x] Add deterministic movement replay test for at least one level
  - File: `src/tests/test_replay.gd` / `src/tests/test_replay.tscn` — replays fixed jump inputs on level 1-1 and asserts final position/time
  - Registered in `src/tests/test_runner.gd`

---

## Phase 2.3 — Clean Up CI/CD & Export Settings

- [ ] Add `src/scripts/singletons/runtime_secrets.gd` and `*_secrets.gd` to `.gitignore`
  - File: `.gitignore`
- [ ] Remove `*.env` from Windows export include filter
  - File: `export_presets.cfg`
- [ ] Unify encryption settings across Windows/Web/Linux presets
  - File: `export_presets.cfg`
  - Decide whether PCK/directory encryption is required; if so, apply consistently
- [ ] Fix `publish_steam` condition string/boolean comparison in workflow
  - File: `.github/workflows/build-and-publish.yml`
- [ ] Add a `test` job to CI that runs `run_tests.sh` headless before any build/publish
  - File: `.github/workflows/build-and-publish.yml`
- [ ] Verify `runtime_secrets.gd` is actually consumed by game code; integrate SilentWolf or remove injection
  - File: `.github/workflows/build-and-publish.yml`

---

## Phase 2.4 — Harden Audio, UI & First-Time Experience

- [ ] Validate bus names in `AudioManager.set_bus_volume` and warn on missing buses
  - File: `src/scripts/singletons/audio_manager.gd`
- [ ] Debounce settings save so sliders do not write disk every frame
  - File: `src/scripts/singletons/settings.gd`
- [ ] Remove accidental `next_button._on_mouse_entered()` call in `end_screen.gd`
  - File: `src/ui/menus/end_screen.gd`
  - Replace with `next_button.grab_focus()` if controller focus is needed
- [ ] Add gamepad bindings for `ui_accept` and `ui_cancel` in `project.godot`
  - File: `project.godot`
- [ ] Ensure every menu calls `grab_focus()` on the primary button for controller navigation
  - Files: `src/ui/menus/main_menu.gd`, `src/ui/menus/level_select.gd`, `src/ui/menus/end_screen.gd`, `src/ui/menus/pause_screen.tscn`
- [ ] Add a loading/transition overlay to `SceneLoader`
  - File: `src/scripts/singletons/scene_loader.gd`
  - Handle `change_scene_to_file` errors and fade in/out

---

## Phase 2.5 — Add Retention & Monetization Hooks

- [ ] Add lightweight analytics abstraction layer
  - File: `src/scripts/singletons/telemetry_system.gd` (new)
  - Events: `level_started`, `level_finished`, `run_restarted`, `powerup_used`, `death` (with reason), `menu_opened`
  - Start with local debug logger; later swap to SilentWolf/GameAnalytics backend
- [ ] Add daily/weekly attempt and time-played counters to `GameData`
  - File: `src/scripts/resources/game_data.gd` and `src/scripts/singletons/save_manager.gd`
- [ ] Add a stats screen accessible from main menu
  - File: `src/ui/menus/` (new scene)
- [ ] Add cosmetic unlock abstraction (hats/skins) tied to medal milestones
  - Files: `src/scripts/resources/medal_config.gd`, `src/ui/menus/level_select.gd`
- [ ] Add an optional IAP/ad layer behind a feature flag
  - File: `src/scripts/singletons/monetization_system.gd` (new)
  - Keep it no-op until store integration is ready

---

## Phase 2.6 — Performance & Architecture Polish

- [ ] Audit `SubViewport` usage in `main.tscn` for unnecessary redraws
  - File: `main.tscn`
  - Use `UPDATE_WHEN_VISIBLE` and smallest needed size
- [ ] Cache `get_children()` calls in `main.gd` `initialize_players`/`update_players` where safe
  - File: `main.gd`
- [ ] Ensure `TileMap.clear()` is called before every level rebuild and bounds are tight
  - File: `src/scenes/level/level.gd`
- [ ] Remove or resolve all TODO/FIXME comments found in audit
  - Files: `main.gd`, `src/scenes/player/player.gd`, `src/scenes/level/level.gd`, `src/scenes/level/terrain_layer.gd`, `src/scenes/training/synchronizer.gd`, `src/scenes/player/states/move_state.gd`
- [ ] Run full test suite and fix any regressions
  - Files: `run_tests.sh`, `run_tests.bat`, `src/tests/test_runner.tscn`