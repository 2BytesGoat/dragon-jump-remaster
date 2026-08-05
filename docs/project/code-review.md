# Code Review Checklist

## Bugs

### Mid-Air Turn Bug
- [ ] MoveState wall-flip while airborne — move_state.gd:12-13: `facing_direction *= -1` fires when `is_on_wall()` is true, even if the player is in the air. Should also check `is_on_floor()`.
- [ ] JumpState transitions to Move while airborne — jump_state.gd:31-33: `was_on_wall and not is_on_wall()` transitions to MoveState even when the player is still falling. Should go to Fall instead.
- [ ] WalledState stale collision — walled_state.gd:55: `get_last_slide_collision()` is one frame behind, so `_get_walled_direction()` can return `Vector2.ZERO`, causing spurious `facing_direction *= -1` (line 51).

### Stale Collision Data (systemic)
- [ ] State machine runs before `move_and_slide()` — player.gd:123-136: `is_on_floor()`, `is_on_wall()`, `is_on_ceiling()` are all one frame behind in every state. Causes delayed wall/ceiling detection in JumpState, delayed wall bounce in MoveState, and the FallState powerup-gating workaround.
- [ ] JumpState ceiling clip — jump_state.gd:25-28: wall/ceiling detection is delayed by a frame, so the player can clip into a ceiling before the "spiderman" modifier kicks in.

### Crash / Safety
- [ ] `_pop_powerup()` no bounds check — player.gd:270: calls `powerups.pop_back()` without checking if the array is empty. `has_powerups()` exists but isn't always called first.
- [ ] `_on_speed_modifier_changed` division by zero — player.gd:304: `1 / speed_modifier` with no zero-guard.
- [ ] `_run_death_sequence` freed-node crash — player.gd:179-191: long coroutine with multiple `await` calls. If the player node is freed mid-sequence, it crashes.
- [ ] `_on_player_controller_changed` double-call leak — player.gd:364-370: creates a new controller and `queue_free()`s children. If called twice, leaks the first controller and orphans the second.

### Gameplay Logic
- [ ] Every static tile is a checkpoint — player.gd:404-407: `_on_interact_box_body_entered` sets `starting_position` on any StaticLayer body contact. Brushing a wall mid-jump moves the respawn point.
- [ ] Hurtbox kills on any TileMapLayer — player.gd:380: `body is TileMapLayer` is too broad. Any TileMapLayer entering the hurtbox triggers death.
- [ ] Secret islands fade together — secrets_layer.gd:135: `_on_secret_area_entered` fades the entire secrets visual layer, not just the entered island.
- [ ] Secret island collision can silently fail — secrets_layer.gd:123-127: `Geometry2D.merge_polygons` can fail, leaving an Area2D with no collision shape. Only a warning is printed.

## Dead / Unreachable Code
- [ ] stomp_state.gd:29-31 — `_on_interact_box_area_entered` is named like a signal handler but lives on a State node with no Area2D children. Never called.
- [ ] grapple_state.gd:23-24 — `_on_grappling_hook_should_release` is never connected to any signal.
- [ ] tile_registry.gd:133-137 — `get_layer_for_type()` always returns null. Comment explains why, but the method still exists.
- [ ] player.gd:133 — `_update_friction()` is commented out. `current_friction` is set but never read.
- [ ] player.gd:54 — `last_floor_position` is written in `MoveState.exit()` and `IdleState.enter()` but never read anywhere.
- [ ] level.gd:127-129 — commented-out test code in `_ready()`.

## Duplicate Code
- [ ] BounceState copy-pastes JumpState — bounce_state.gd:36-45 and jump_state.gd:24-33 are identical wall/ceiling/floor logic. bounce_state.gd:55-59 and jump_state.gd:48-52 are identical `_on_jump_timer_timeout`. BounceState should extend JumpState.
- [ ] Weighted random pick duplicated — terrain_layer.gd:129-146 and utils.gd:7-25 are the same function. Use one.
- [ ] Two different Dijkstra implementations — level.gd:803-850 (4-directional, linear-scan priority queue) and utils.gd:78-119 (8-directional, BFS queue). Inconsistent movement model.

## Performance
- [ ] LevelCodeParser creates a new TileRegistry per character — level_code_parser.gd:71: `_TileRegistry.default()` instantiates a full TileRegistry for every single character parsed. Cache it.
- [ ] `_process` calls `_init_terrain_layer` every frame in editor — level.gd:148-152: runs every frame even when nothing changed.
- [ ] Flow field uses O(n²) priority queue — level.gd:803-850: linear scan for min-distance node. Since all costs are 1 or INF, a simple BFS queue would be O(n).

## Dangerous Patterns
- [ ] `_export_level_code_to_level_gd()` modifies its own source file — level.gd:362-394: opens its own `.gd` file, regex-searches for a function call, and overwrites the file. Fragile and dangerous. Remove in favor of `_save_level_code_to_tmp_preview()`.

## Naming & Consistency
- [ ] grapple_state.gd:1 — `class_name Grapple` instead of `GrappleState`. All other states end in "State".
- [ ] card_container_container.gd — joke name that shipped. Rename to PowerupHUD or CardHUD.
- [ ] constants.gd and utils.gd in scripts/singletons/ — they are NOT autoloads. Move out of singletons/.

## AI Leaking into Player
- [ ] player.gd:93 — `var level_reference: Level` — only used by the AI controller. Move to PlayerAITrainingController.
- [ ] player.gd:94 — `var last_agent_input: bool` — only used by the AI controller. Move to PlayerAITrainingController.
- [ ] player.gd:151-152 — `set_jump()` has a `last_agent_input` dedup check that only exists for the AI. Move to controller.

## File Organization
- [ ] Loose scripts at src/scenes/ — camera_2d.gd, level_select_camera_2d.gd not in any subdirectory.
- [ ] State base classes split across trees — scripts/components/states/ (base) vs scenes/player/states/ (implementations).
- [ ] tile_registry.gd and level_code_parser.gd in scripts/resources/ — they are systems, not resource definitions.
- [ ] card_container_container.gd in scenes/powerups/ — it's a UI component, not a powerup.
- [ ] synchronizer.gd in scenes/training/ — ML code mixed with game scenes.
- [ ] Command pattern deeply nested — scripts/components/patterns/command.gd for 7 lines.

## level.gd — Too Many Responsibilities (881 lines)
- [ ] Extract LevelCodeExporter — serialization + editor export buttons (lines 220-259, 332-464).
- [ ] Extract DecorationSpawner — grass + vines (lines 623-742).
- [ ] Extract FlowField — Dijkstra computation (lines 803-850).
- [ ] Extract ObjectPopulator — object instantiation from tile data (lines 576-617).
- [ ] Replace populated_cells string concatenation — level.gd:856-859: `Dictionary[Vector2i, String]` where "WY" means wall+spikes. Use `Array[String]` or a bitmask.
- [ ] Clarify _fill_rectangle_with_walls — level.gd:485-498: bidirectional fill is clever but opaque. Replace with a simple "fill all empty cells with walls" loop.
- [ ] Clarify _set_multiple_cells string iteration — level.gd:507: iterating characters of a string is implicit. Add a dedicated multi-tile instruction type or document the behavior.

## Suggested Restructuring Plan

### Phase 1: Bug Fixes (do first)
- [ ] Fix mid-air turn bug (3 items above)
- [ ] Fix stale collision data (2 items above)
- [ ] Fix crash/safety issues (4 items above)
- [ ] Fix gameplay logic issues (4 items above)

### Phase 2: Cleanup
- [ ] Remove dead/unreachable code (6 items above)
- [ ] Fix naming & consistency (3 items above)
- [ ] Move AI state out of Player (3 items above)
- [ ] Remove `_export_level_code_to_level_gd()` dangerous pattern

### Phase 3: Deduplicate
- [ ] BounceState extends JumpState
- [ ] Unify weighted random pick
- [ ] Unify Dijkstra implementations

### Phase 4: Performance
- [ ] Cache TileRegistry in LevelCodeParser
- [ ] Fix editor `_process` spam
- [ ] Replace flow field priority queue with BFS

### Phase 5: Reorganize
- [ ] Split level.gd into smaller classes
- [ ] Reorganize directory structure
- [ ] Replace populated_cells string concatenation