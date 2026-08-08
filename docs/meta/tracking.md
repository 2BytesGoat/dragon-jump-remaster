---
title: Documentation Tracking
tags: [godot, game-engine, documentation, tracking, index]
related:
  - "[[meta/process]]"
  - "[[meta/compliance-checklist]]"
  - "[[index]]"
search_terms: [documentation-tracking, file-tracker, systems, gdscript, tscn]
---

# File Tracker for Documentation

This document tracks all `.gd` and `.tscn` files in the repository, organized by component type.

> [!NOTE]
> The docs vault is organized into five areas:
> - `design/` — Game design documents (GDD, product identity, release plan)
> - `technical/` — Technical reference documentation for each code system
> - `project/` — Project management (sprints, backlog, decisions, checklists)
> - `future/` — Shelved features and research ideas
> - `meta/` — Documentation about documentation
>
> See `[[meta/process]]` for documentation standards and workflow.

## Main System Files

- [x] main.gd — documented in [[technical/main-system]]
- [x] main.tscn — documented in [[technical/main-system]]

## Player System

- [x] src/scenes/player/player.gd — documented in [[technical/player-system]]
- [x] src/scenes/player/player.tscn — documented in [[technical/player-system]]
- [x] src/scenes/player/ghost.gd — documented in [[technical/player-system]]
- [x] src/scenes/player/ghost.tscn — documented in [[technical/player-system]]
- [x] src/scenes/player/grappling_hook.gd — documented in [[technical/player-system]]
- [x] src/scenes/player/observer.gd — documented in [[technical/player-system]]
- [x] src/scenes/player/state_label.gd — documented in [[technical/player-system]]
- [ ] src/scenes/player/controller/player_one_controller.gd
- [ ] src/scenes/player/controller/player_character_controller.gd
- [ ] src/scenes/player/controller/player_ai_training_controller.gd
- [ ] src/scenes/player/controller/commands/jump_command.gd
- [ ] src/scenes/player/controller/commands/reset_command.gd
- [ ] src/scenes/player/states/idle_state.gd
- [ ] src/scenes/player/states/move_state.gd
- [ ] src/scenes/player/states/jump_state.gd
- [ ] src/scenes/player/states/fall_state.gd
- [ ] src/scenes/player/states/walled_state.gd
- [ ] src/scenes/player/states/double_jump_state.gd
- [ ] src/scenes/player/states/dash_state.gd
- [ ] src/scenes/player/states/stomp_state.gd
- [ ] src/scenes/player/states/bounce_state.gd
- [ ] src/scenes/player/states/grapple_state.gd
- [ ] src/scenes/player/states/die_state.gd
- [ ] src/scenes/player/states/celebrate_state.gd
- [ ] src/scenes/player/sensors/raycast_sensor.tscn

## Level Component

- [x] src/scenes/level/level.gd — documented in [[technical/level-system/index]]
- [x] src/scenes/level/level.tscn — documented in [[technical/level-system/index]]
- [x] src/scenes/level/level_background.gd — documented in [[technical/level-system/background]]
- [x] src/scenes/level/level_wall_blend.gd — documented in [[technical/level-system/wall-blend]]
- [x] src/scenes/level/secrets_layer.gd — documented in [[technical/level-system/secrets-layer]]
- [x] src/scenes/level/terrain_layer.gd — documented in [[technical/level-system/terrain-layer]]
- [ ] src/scenes/level/tiles/bounce_pad.gd
- [ ] src/scenes/level/tiles/bounce_pad.tscn
- [ ] src/scenes/level/tiles/dissolve_block.gd
- [ ] src/scenes/level/tiles/dissolve_block.tscn
- [ ] src/scenes/level/tiles/grass.gd
- [ ] src/scenes/level/tiles/grass.tscn
- [ ] src/scenes/level/tiles/portal.tscn
- [ ] src/scenes/level/tiles/slippery_floor.tscn
- [ ] src/scenes/level/tiles/destroyable_block.tscn
- [ ] src/scenes/level/tiles/vines.tscn

## Save System

- [x] src/scripts/singletons/save_manager.gd — documented in [[technical/save-system/index]]
- [x] src/scripts/resources/game_data.gd — documented in [[technical/save-system/game-data]]
- [x] src/scripts/resources/level_data.gd — documented in [[technical/save-system/level-data]]
- [x] src/scripts/resources/campaign_level_data.gd — documented in [[technical/save-system/campaign-level-data]]

## Leaderboard System

- [x] src/ui/widgets/leaderboard.gd — documented in [[technical/leaderboard]]
- [x] src/ui/widgets/leaderboard.tscn — documented in [[technical/leaderboard]]
- [x] src/ui/widgets/leaderboard_entry.gd — documented in [[technical/leaderboard]]
- [x] src/ui/widgets/leaderboard_entry.tscn — documented in [[technical/leaderboard]]

## RL Integration System

- [x] addons/godot_rl_agents/sync.gd — documented in [[technical/rl-integration]]
- [x] src/scripts/singletons/signal_bus.gd — documented in [[technical/signal-bus]]

## UI Components

- [x] src/ui/menu/main_menu.gd — documented in [[technical/ui/index]]
- [x] src/ui/menu/main_menu.tscn — documented in [[technical/ui/index]]
- [x] src/ui/menu/main_screen.gd — documented in [[technical/ui/index]]
- [x] src/ui/menu/main_screen.tscn — documented in [[technical/ui/index]]
- [x] src/ui/menu/practice_menu.gd — documented in [[technical/ui/index]]
- [x] src/ui/menu/practice_menu.tscn — documented in [[technical/ui/index]]
- [x] src/ui/menu/credits.gd — documented in [[technical/ui/index]]
- [x] src/ui/menu/credits.tscn — documented in [[technical/ui/index]]
- [x] src/ui/gameplay/end.gd — documented in [[technical/ui/index]]
- [x] src/ui/gameplay/end.tscn — documented in [[technical/ui/index]]
- [ ] src/ui/widgets/level_button.gd
- [ ] src/ui/widgets/level_button.tscn
- [ ] src/ui/widgets/speed_slider_label.gd
- [ ] src/ui/widgets/menu_button.gd
- [ ] src/ui/widgets/menu_button.tscn
- [ ] src/ui/widgets/others_label.tscn
- [ ] src/ui/gameplay/pause.gd
- [ ] src/ui/gameplay/pause.tscn
- [x] src/ui/widgets/crt_effect.gd — documented in [[technical/main-system]]
- [x] src/ui/widgets/crt_effect.tscn — documented in [[technical/main-system]]
- [ ] src/ui/gameplay/settings.gd
- [ ] src/ui/gameplay/settings.tscn
- [ ] src/ui/gameplay/game_over.gd
- [ ] src/ui/gameplay/game_over.tscn
- [x] src/ui/gameplay/hud.gd — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/gameplay/hud.tscn — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/widgets/time_display.gd — documented in [[technical/ui/arcade-hud]]
- [x] src/scripts/components/run_timer.gd — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/gameplay/bonus_popup.gd — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/gameplay/bonus_popup.tscn — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/themes/default_theme.tres — documented in [[technical/ui/index]]
- [x] src/ui/themes/gameplay_theme.tres — documented in [[technical/ui/arcade-hud]]
- [x] src/ui/themes/practice_theme.tres — documented in [[technical/ui/index]]

## Effects

- [x] src/scenes/effects/background_particles.gd — documented in [[technical/effects]]
- [x] src/scenes/effects/background_particles.tscn — documented in [[technical/effects]]
- [x] src/scenes/effects/despawn_smoke_effect.gd — documented in [[technical/effects]]
- [x] src/scenes/effects/despawn_smoke_effect.tscn — documented in [[technical/effects]]
- [x] src/scenes/effects/jump_smoke_effect.gd — documented in [[technical/effects]]
- [x] src/scenes/effects/jump_smoke_effect.tscn — documented in [[technical/effects]]
- [x] src/scenes/effects/spawn_smoke_effect.gd — documented in [[technical/effects]]
- [x] src/scenes/effects/spawn_smoke_effect.tscn — documented in [[technical/effects]]
- [ ] src/scenes/effects/hit_stop.gd
- [ ] src/scenes/effects/hit_stop.tscn
- [ ] src/scenes/effects/screen_shake.gd
- [ ] src/scenes/effects/screen_shake.tscn
- [x] src/scenes/effects/transition_wipe.gd — documented in [[technical/effects]]
- [x] src/scenes/effects/transition_wipe.tscn — documented in [[technical/effects]]

## Powerups

- [x] src/scenes/powerups/powerup.gd — documented in [[technical/powerups]]
- [x] src/scenes/powerups/powerup.tscn — documented in [[technical/powerups]]
- [x] src/scenes/powerups/card_scene.gd — documented in [[technical/powerups]]
- [x] src/scenes/powerups/card_scene.tscn — documented in [[technical/powerups]]
- [ ] src/scenes/powerups/card_container.gd
- [ ] src/scenes/powerups/card_container_container.gd

## Training System

- [x] src/scenes/training/synchronizer.gd — documented in [[technical/training]]

## Other Scripts / Shared Components

- [x] src/scripts/singletons/constants.gd — documented in [[technical/utilities]]
- [x] src/scripts/singletons/runtime_secrets.gd.template — build-time template; copy to `runtime_secrets.gd` with real values. Never committed.
- [x] src/scripts/singletons/scene_loader.gd — documented in [[technical/utilities]]
- [x] src/scripts/singletons/utils.gd — documented in [[technical/utilities]]
- [x] src/scripts/singletons/arcade_director.gd — Arcade mode run controller; V1.0 autoload
- [x] src/scripts/singletons/telemetry_system.gd — Local analytics abstraction; V1.0 autoload
- [x] src/scripts/singletons/audio_manager.gd — V1.0 autoload
- [x] src/scripts/singletons/game_session.gd — V1.0 autoload
- [x] src/scripts/singletons/settings.gd — V1.0 autoload
- [ ] src/scripts/components/states/state.gd
- [ ] src/scripts/components/states/state_machine.gd
- [ ] src/scripts/components/patterns/command.gd
- [ ] src/scripts/resources/arcade_config.gd
- [ ] src/scripts/resources/audio_bus_config.gd
- [ ] src/scripts/resources/bonus_popup_config.gd — documented in [[technical/ui/arcade-hud]]
- [ ] src/scripts/resources/campaign_level_library.gd
- [ ] src/scripts/resources/level_code_parser.gd
- [ ] src/scripts/resources/medal_config.gd
- [ ] src/scripts/resources/physics_params.gd
- [ ] src/scripts/resources/powerup_palette.gd
- [ ] src/scripts/resources/settings_data.gd
- [ ] src/scripts/resources/tile_registry.gd
- [ ] src/scenes/camera_2d.gd
- [ ] src/scenes/level_select_camera_2d.gd
- [ ] src/scenes/level/parallax_auto_fit.gd

## Project Direction and Tracking

- [x] `docs/design/product-identity.md` — Refined product identity
- [x] `docs/design/vision-and-goals.md` — Long-term goals and project context
- [x] `docs/design/core-loop.md` — Core gameplay loop and mechanics
- [x] `docs/design/progression-and-meta.md` — Campaign progression and meta
- [x] `docs/design/release-plan.md` — EA (Dec 2026, $9.99) + 1.0 (Aug 2027, $12.99) plan
- [x] `docs/design/ai-training-mode.md` — Hidden AI training mode design
- [x] `docs/design/arcade-mode.md` — Arcade mode design reference
- [x] `docs/project/decisions.md` — Decision log (incl. 2026-08-05 editor-first EA pivot)
- [x] `docs/project/current-sprint.md` — Current sprint focus
- [x] `docs/project/active-backlog.md` — Active backlog (Phase 0 pipeline → Phase 5 1.0 launch)
- [x] `docs/project/sprints/sprint-2026-09-30.md` — EA Sprint 1: editor foundation + world reorg
- [x] `docs/project/sprints/sprint-2026-10-31.md` — EA Sprint 2: Workshop + arcade + boss levels
- [x] `docs/project/sprints/sprint-2026-11-30.md` — EA Sprint 3: EA build complete + store prep
- [x] `docs/project/sprints/sprint-2026-12-15.md` — EA launch sprint (Dec 2026)
- [x] `docs/future/shelved-features.md` — Features shelved for EA/1.0 (incl. roguelike, 2026-08-05)
- [x] `docs/future/research-ideas.md` — Future AI/RL research directions
- [x] `docs/project/game-juice-plan.md` — Game juice / reward-loop polish plan

## Archived

- [x] `docs/archive/project-notes.md` — Legacy decision log; content has been split into `design/`, `project/`, and `future/`.