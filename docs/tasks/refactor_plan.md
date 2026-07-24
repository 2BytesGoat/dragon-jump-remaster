> # Refactor Plan — Dragon Jump Remaster

Phase 1 execution plan. Each task is small enough to hand to a freelancer or to run as a single focused session.

---

## Phase 1.1 — Delete Dead Systems

- [ ] Delete `src/scenes/training/main_multiplayer.gd` and `.tscn` ✅ Done
- [ ] Delete `src/scenes/training/multiplayer_world.gd` and `.tscn` ✅ Done
- [ ] Remove `MULTIPLAYER_LEVELS` from `Constants.gd` ✅ Done
- [ ] Remove `main_multiplayer` button from `main_menu.tscn` and `main_menu.gd` ✅ Done
- [ ] Remove crown/tile-tag dead code from `level.gd` ✅ Done (`first_time_touching_crown` removed)
- [ ] Remove `emplased_time` / `elapsed_time` dead variable from `level.gd` ✅ Done
- [ ] Audit `src/scenes/training/` for any remaining multiplayer or AI crossover files
- [ ] Audit `src/scenes/ui/` for placeholder/dead screens and remove or flag them

## Phase 1.2 — Fix Naming Debt

- [ ] Rename `SceneManger` → `SceneManager` across code and scenes ✅ Done
- [ ] Rename `GaplingHook` → `GrapplingHook`
- [ ] Rename `preogress_bar` (if it exists) → `progress_bar`
- [ ] Rename `CampaingLevelData` (if it exists) → `CampaignLevelData`
- [ ] Rename `last_agent_intput` (if it exists) → `last_agent_input`
- [ ] Standardize file/class naming: PascalCase files and classes, snake_case signals/variables

## Phase 1.3 — Shrink Autoloads

- [ ] Convert `Utils` autoload to `class_name Utils` with static helpers
- [ ] Convert `SignalBus` autoload: keep only cross-scene signals; replace local ones
- [ ] Move `Constants` level lists into `LevelData` Resource files
- [ ] Move physics tuning from `Constants`/`level.gd` into `PhysicsParams` Resource
- [ ] Move powerup/medal colors from `Constants` into `PowerupPalette`/`MedalConfig` Resources
- [ ] Fold `RuntimeSecrets` and `EnvironmentVariables` into `Settings` or remove if unused
- [ ] Decide fate of `LeaderboardManager` and `SilentWolf` addon (local-only vs remove)

## Phase 1.4 — Move Data into Resources

- [ ] Create `res://resources/physics_params.tres`
- [ ] Create `res://resources/level_data/` folder and one `.tres` per V1.0 level
- [ ] Create `res://resources/powerup_palette.tres`
- [ ] Create `res://resources/medal_config.tres`
- [ ] Create `res://resources/audio_bus_config.tres`
- [ ] Refactor `level.gd` to load `LevelData` instead of parsing inline symbol strings

## Phase 1.5 — Add Smoke Tests

- [ ] Create `tests/test_boot.gd`: game boots to main menu
- [ ] Create `tests/test_level_load.gd`: each V1.0 level loads from symbol code
- [ ] Create `tests/test_save_score.gd`: finish a run, save score, reload it
- [ ] Wire tests to a CI script or a run-one-test-scene so they can be run headlessly

## Phase 1.6 — Documentation Sync

- [ ] Update `docs/systems/architecture.md` with final autoload roster ✅ Done
- [ ] Update `docs/direction/release_plan.md` with locked V1.0 scope ✅ Done
- [ ] Update `docs/tracking/decisions.md` ✅ Done
- [ ] Create `docs/direction/ai_training_mode.md`
- [ ] Update `docs/backlog/shelved_features.md` to reflect what was removed vs deferred
