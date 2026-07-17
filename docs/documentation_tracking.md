# File Tracker for Documentation

This document tracks all `.gd` and `.tscn` files in the repository, organized by component type. It also points to the new project direction and tracking documents.

> [!NOTE]
> The Obsidian vault is now split into four areas:
> - `direction/` — GDD and product identity
> - `tracking/` — sprints, backlog, and decision log
> - `backlog/` — shelved features and research ideas
> - `systems/` — technical reference documentation
>
> Documentation structures may evolve over time. Cross-reference `docs/documentation_process.md` for the most up-to-date requirements.

## Main System Files

- [x] main.gd - (Added documentation to /docs/systems/main_system/main_system.md)
- [x] main.tscn - (Added documentation to /docs/systems/main_system/main_system.md)

## Player System

- [x] src/scenes/player/player.gd - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/player.tscn - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/ghost.gd - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/ghost.tscn - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/gapling_hook.gd - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/observer.gd - (Added documentation to /docs/systems/player_system/player_system.md)
- [x] src/scenes/player/state_label.gd - (Added documentation to /docs/systems/player_system/player_system.md)
- [ ] src/scenes/player/controller/player_one_controller.gd - (Not yet documented)
- [ ] src/scenes/player/controller/player_two_controller.gd - (Not yet documented)
- [ ] src/scenes/player/controller/player_character_controller.gd - (Not yet documented)
- [ ] src/scenes/player/controller/player_ai_training_controller.gd.gd - (Not yet documented)
- [ ] src/scenes/player/controller/commands/jump_command.gd - (Not yet documented)
- [ ] src/scenes/player/controller/commands/reset_command.gd - (Not yet documented)
- [ ] src/scenes/player/states/idle_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/move_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/jump_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/fall_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/walled_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/double_jump_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/dash_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/stomp_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/bounce_state.gd - (Not yet documented)
- [ ] src/scenes/player/states/swing_state.gd - (Not yet documented)
- [ ] src/scenes/player/sensors/raycast_sensor.tscn - (Not yet documented)

## Level Component

- [x] src/scenes/level/level.gd - (Added documentation to /docs/systems/level_system/level_system.md)
- [x] src/scenes/level/level.tscn - (Added documentation to /docs/systems/level_system/level_system.md)
- [x] src/scenes/level/level_background.gd - (Added documentation to /docs/systems/level_system/level_background_system.md)
- [x] src/scenes/level/level_wall_blend.gd - (Added documentation to /docs/systems/level_system/level_wall_blend_system.md)
- [x] src/scenes/level/secrets_layer.gd - (Added documentation to /docs/systems/level_system/secrets_layer_system.md)
- [x] src/scenes/level/terrain_layer.gd - (Added documentation to /docs/systems/level_system/terrain_layer_system.md)
- [ ] src/scenes/level/tiles/bounce_pad.gd - (Not yet documented)
- [ ] src/scenes/level/tiles/bounce_pad.tscn - (Not yet documented)
- [ ] src/scenes/level/tiles/crown.gd - (Not yet documented)
- [ ] src/scenes/level/tiles/crown.tscn - (Not yet documented)
- [ ] src/scenes/level/tiles/dissolve_block.gd - (Not yet documented)
- [ ] src/scenes/level/tiles/dissolve_block.tscn - (Not yet documented)
- [ ] src/scenes/level/tiles/portal.tscn - (Not yet documented)
- [ ] src/scenes/level/tiles/slippery_floor.tscn - (Not yet documented)
- [ ] src/scenes/level/tiles/destroyable_block.tscn - (Not yet documented)

## Save System

- [x] src/scripts/singletons/save_manager.gd - (Added documentation to /docs/systems/save_system/save_system.md)
- [x] src/scripts/resources/game_data.gd - (Added documentation to /docs/systems/save_system/game_data.md)
- [x] src/scripts/resources/level_data.gd - (Added documentation to /docs/systems/save_system/level_data.md)
- [x] src/scripts/resources/campaing_level_data.gd - (Added documentation to /docs/systems/save_system/campaing_level_data.md)

## Leaderboard System

- [x] src/scripts/singletons/leaderboard_manager.gd - (Added documentation to /docs/systems/leaderboard_system/leaderboard_system.md)
- [x] src/ui/components/leaderboard.gd - (Added documentation to /docs/systems/leaderboard_system/leaderboard_system.md)
- [x] src/ui/components/leaderboard.tscn - (Added documentation to /docs/systems/leaderboard_system/leaderboard_system.md)
- [x] src/ui/components/leaderboard_entry.gd - (Added documentation to /docs/systems/leaderboard_system/leaderboard_system.md)
- [x] src/ui/components/leaderboard_entry.tscn - (Added documentation to /docs/systems/leaderboard_system/leaderboard_system.md)

## RL Integration System

- [x] addons/godot_rl_agents/sync.gd - (Added documentation to /docs/systems/rl_integration_system/rl_integration_system.md)
- [x] src/scripts/singletons/signal_bus.gd - (Added documentation to /docs/systems/rl_integration_system/rl_integration_system.md)
- [ ] src/scenes/training/synchronizer.gd - (Custom synchronizer not yet documented)
- [ ] src/scenes/training/multiplayer_world.gd - (Not yet documented)

## UI Components

- [x] src/ui/end_screen.gd - (Added documentation to /docs/systems/ui_components/ui_components.md)
- [x] src/ui/components/progress_bar.gd - (Added documentation to /docs/systems/ui_components/ui_components.md)
- [x] src/ui/menus/main_menu.gd - (Added documentation to /docs/systems/ui_components/ui_components.md)
- [x] src/ui/menus/main_menu.tscn - (Added documentation to /docs/systems/ui_components/ui_components.md)
- [ ] src/ui/menus/level_select.gd - (Not yet documented)
- [ ] src/ui/menus/level_button.gd - (Not yet documented)
- [ ] src/ui/menus/tag_screen.gd - (Not yet documented)
- [ ] src/ui/menus/speed_slider_label.gd - (Not yet documented)
- [ ] src/ui/menus/menu_button.gd - (Not yet documented)
- [ ] src/ui/menus/others_label.tscn - (Not yet documented)
- [ ] src/ui/menus/pause_screen.tscn - (Not yet documented)
- [ ] src/ui/components/leaderboard.gd - (Documented in /docs/systems/leaderboard_system/leaderboard_system.md)
- [ ] src/ui/components/leaderboard_entry.gd - (Documented in /docs/systems/leaderboard_system/leaderboard_system.md)

## Effects

- [x] src/scenes/effects/background_particles.gd - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/background_particles.tscn - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/despawn_smoke_effect.gd - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/despawn_smoke_effect.tscn - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/jump_smoke_effect.gd - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/jump_smoke_effect.tscn - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/spawn_smoke_effect.gd - (Added documentation to /docs/systems/effects/effects.md)
- [x] src/scenes/effects/spawn_smoke_effect.tscn - (Added documentation to /docs/systems/effects/effects.md)

## Powerups

- [x] src/scenes/powerups/powerup.gd - (Added documentation to /docs/systems/powerups/powerups.md)
- [x] src/scenes/powerups/powerup.tscn - (Added documentation to /docs/systems/powerups/powerups.md)
- [x] src/scenes/powerups/card_scene.gd - (Added documentation to /docs/systems/powerups/powerups.md)
- [x] src/scenes/powerups/card_scene.tscn - (Added documentation to /docs/systems/powerups/powerups.md)
- [ ] src/scenes/powerups/card_container.gd - (Not yet documented)
- [ ] src/scenes/powerups/card_container_container.gd - (Not yet documented)

## Training System

- [x] src/scenes/training/main_multiplayer.gd - (Added documentation to /docs/systems/training_system/training_system.md)
- [x] src/scenes/training/main_multiplayer.tscn - (Added documentation to /docs/systems/training_system/training_system.md)
- [x] src/scenes/training/synchronizer.gd - (Added documentation to /docs/systems/training_system/training_system.md)
- [ ] src/scenes/training/multiplayer_world.gd - (Not yet documented)
- [ ] src/scenes/training/multiplayer_world.tscn - (Not yet documented)

## Other Scripts / Shared Components

- [x] src/scripts/singletons/constants.gd - (Added documentation to /docs/systems/other_scripts/other_scripts.md)
- [x] src/scripts/singletons/environment_variables.gd - (Added documentation to /docs/systems/other_scripts/other_scripts.md)
- [x] src/scripts/singletons/runtime_secrets.gd - (Added documentation to /docs/systems/other_scripts/other_scripts.md)
- [x] src/scripts/singletons/scene_manger.gd - (Added documentation to /docs/systems/other_scripts/other_scripts.md)
- [x] src/scripts/singletons/utils.gd - (Added documentation to /docs/systems/other_scripts/other_scripts.md)
- [ ] src/scripts/components/states/state.gd - (Not yet documented)
- [ ] src/scripts/components/states/state_machine.gd - (Not yet documented)
- [ ] src/scripts/components/patterns/command.gd - (Not yet documented)
- [ ] src/scenes/camera_2d.gd - (Not yet documented)
- [ ] src/scenes/level_select_camera_2d.gd - (Not yet documented)

## Project Direction and Tracking

- [x] `docs/direction/product_identity.md` — Refined product identity
- [x] `docs/direction/vision_and_goals.md` — Long-term goals and project context
- [x] `docs/direction/core_loop.md` — Core gameplay loop and mechanics
- [x] `docs/direction/progression_and_meta.md` — Campaign progression and meta
- [x] `docs/direction/release_plan.md` — V1.0 scope and release plan
- [x] `docs/direction/ai_training_mode.md` — Hidden AI training mode design
- [x] `docs/tracking/decisions.md` — Decision log (replaces `project_notes.md`)
- [x] `docs/tracking/current_sprint.md` — Current sprint focus
- [x] `docs/tracking/backlog.md` — Active backlog
- [x] `docs/backlog/shelved_features.md` — Features shelved for V1.0
- [x] `docs/backlog/research_ideas.md` — Future AI/RL research directions

## Project Notes (Archived)

- [x] `docs/project_notes/project_notes.md` — Legacy decision log; content has been split into `direction/`, `tracking/`, and `backlog/`.
