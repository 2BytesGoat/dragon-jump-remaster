---
title: AI Training Mode
tags: [godot, game-engine, gdd, ai, rl, training, godot-rl-agents, hidden-feature]
related:
  - "[[direction/product_identity]]"
  - "[[direction/release_plan]]"
  - "[[systems/rl_integration_system/rl_integration_system]]"
  - "[[systems/training_system/training_system]]"
search_terms: [ai-training, reinforcement-learning, godot-rl-agents, synchronizer, hidden-mode]
---

# AI Training Mode

## Positioning

The AI training mode is a **hidden/tinkerer feature**, not the main product. It is most valuable for:

- Steam players who want to experiment with reinforcement learning.
- ML workshops where participants train agents to speedrun levels.

## How it works

The project integrates `godot-rl-agents` and exposes the game as a Gym-like environment:

- Observations come from the player state and level context.
- Actions are sent from a Python training process over TCP.
- A custom synchronizer (`src/scenes/training/synchronizer.gd`) pauses the engine between steps.

See `[[systems/rl_integration_system/rl_integration_system]]` and `[[systems/training_system/training_system]]` for technical details.

## Launch options

Open decision: how is the mode exposed?

| Option | Pros | Cons |
|--------|------|------|
| Hidden menu in the same build | Easy to discover for tinkerers | Risk of casual players breaking their save or getting confused |
| Separate launch flag / build | Clean separation | Requires maintaining another export target |
| Arcade build excludes it | Smaller arcade footprint | Less value for arcade-community AI workshops |

## Current competition needs

See `[[tracking/sprints/sprint_2026_07_25]]` for the current sprint plan.

## Future direction

- Keep the AI controller working for the current player character.
- Consider a cleaner observation interface so the AI does not need to reach into internal player state.
- Document the Python/Godot training pipeline more thoroughly after V1.0.

## Known limitations

- `PlayerAITrainingController` is tightly coupled to `player.level_reference`, `player.state_machine`, and `player.global_position`.
- `main_multiplayer.gd` has a hardcoded default level (`1-14`) and a TODO to loop through all levels.
- The custom synchronizer (`src/scenes/training/synchronizer.gd`) is not yet documented in the technical system docs.