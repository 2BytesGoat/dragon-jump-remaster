> # Refactor Plan — Dragon Jump Remaster

Phase 1 execution plan. Each task is small enough to hand to a freelancer or to run as a single focused session.

---

## Phase 1.1 — Delete Dead Systems

- [x] Delete `src/scenes/training/main_multiplayer.gd` and `.tscn`
- [x] Delete `src/scenes/training/multiplayer_world.gd` and `.tscn`
- [x] Remove `MULTIPLAYER_LEVELS` from `Constants.gd`
- [x] Remove `main_multiplayer` button from `main_menu.tscn` and `main_menu.gd`
- [x] Remove crown/tile-tag dead code from `level.gd`
- [x] Remove `emplased_time` / `elapsed_time` dead variable from `level.gd`
- [x] Audit `src/scenes/training/` for any remaining multiplayer or AI crossover files
- [x] Audit `src/scenes/ui/` for placeholder/dead screens and remove or flag them

## Phase 1.2 — Fix Naming Debt

- [x] Rename `SceneManger` → `SceneManager` across code and scenes
- [x] Rename `GaplingHook` → `GrapplingHook`
- [x] Rename `preogress_bar` (if it exists) → `progress_bar`
- [x] Rename `CampaingLevelData` (if it exists) → `CampaignLevelData`
- [x] Rename `last_agent_intput` (if it exists) → `last_agent_input`
- [x] Standardize file/class naming: PascalCase files and classes, snake_case signals/variables

## Phase 1.3 — Shrink Autoloads

- [x] Convert `Utils` autoload to `class_name Utils` with static helpers
- [x] Convert `SignalBus` autoload: keep only cross-scene signals; replace local ones
- [x] Move `Constants` level lists into `LevelData` Resource files
- [x] Move physics tuning from `Constants`/`level.gd` into `PhysicsParams` Resource
- [x] Move powerup/medal colors from `Constants` into `PowerupPalette`/`MedalConfig` Resources
- [x] Fold `RuntimeSecrets` and `EnvironmentVariables` into `Settings` or remove if unused
- [x] Decide fate of `LeaderboardManager` and `SilentWolf` addon (local-only vs remove)

## Phase 1.4 — Move Data into Resources

- [x] Create `res://resources/physics_params.tres`
- [x] Create `res://resources/level_data/` folder and one `.tres` per V1.0 level
- [x] Create `res://resources/powerup_palette.tres`
- [x] Create `res://resources/medal_config.tres`
- [x] Create `res://resources/audio_bus_config.tres`
- [x] Refactor `level.gd` to load `LevelData` instead of parsing inline symbol strings

## Phase 1.5 — Add Smoke Tests

- [x] Create `src/tests/test_boot.gd` + `.tscn`: game boots to main menu
- [x] Create `src/tests/test_level_load.gd` + `.tscn`: each V1.0 level loads from symbol code
- [x] Create `src/tests/test_save_score.gd` + `.tscn`: finish a run, save score, reload it
- [x] Wire tests to `src/tests/test_runner.tscn` and `run_tests.sh` / `run_tests.bat` for headless runs

## Phase 1.6 — Documentation Sync

- [ ] Update `docs/systems/architecture.md` with final autoload roster ✅ Done
- [ ] Update `docs/direction/release_plan.md` with locked V1.0 scope ✅ Done
- [ ] Update `docs/tracking/decisions.md` ✅ Done
- [ ] Create `docs/direction/ai_training_mode.md`
- [ ] Update `docs/backlog/shelved_features.md` to reflect what was removed vs deferred

## Phase 1.7 — Performance & Architecture Audit

- [x] Audit `project.godot` autoload roster; remove any singleton that is not a cross-scene concern
- [x] Audit each file in `src/scripts/singletons/` for scene-local state leaks; move scene state into owning scenes
- [x] Convert cross-scene communication to signals; remove direct node manipulation from autoloads
- [x] Audit SubViewport usage in `src/ui/components/`; remove from latency-sensitive HUD if present
- [ ] Reconfigure unavoidable SubViewports: smallest size, no `stretch=true` + manual resize, `UPDATE_WHEN_VISIBLE`/`UPDATE_ONCE`
- [x] Verify `TileMap.clear()` is called before every symbol-based level rebuild in `level.gd` / parser
- [ ] Verify TileMap bounds match playable area; eliminate oversized empty tile layers
- [x] Cache node references with `@onready` in `player_one_controller.gd` and `level.gd`; remove `get_node()` from `_process`/`_physics_process`
- [x] Ensure movement/collision logic lives in `_physics_process`; keep visual interpolation in `_process`
- [x] Audit signal connections for duplicates on reload; disconnect in `_exit_tree` or use one-shot where safe
- [x] Audit `await` chains for dangling coroutines when scenes change
- [x] Verify `duplicate()` usage on Resources in `src/resources/` and gameplay code; keep base resources immutable
- [x] Confirm save/telemetry writes are gated through dedicated `SaveSystem`/`TelemetrySystem`
- [x] Validate save data on load with fallback defaults; never crash on corrupt or missing save file
- [x] Confirm AI training scene is fully decoupled: arcade boot never instantiates or connects training nodes/signals
- [x] Add frame-time smoke test: 60 fps stable during level load and first 30 seconds of gameplay
