---
title: Research Ideas
tags: [godot, game-engine, backlog, research, ai, rl, experiments]
related:
  - "[[direction/ai_training_mode]]"
  - "[[tracking/backlog]]"
  - "[[backlog/shelved_features]]"
search_terms: [research, ai, rl, experiments, future, observations, curriculum]
---

# Research Ideas

These are experiments and research directions related to the AI training mode. They are not part of V1.0.

## RL training improvements

- **Cleaner observation interface:** Decouple the AI controller from internal player state (`level_reference`, `state_machine`, `global_position`).
- **Curriculum learning:** Train agents on progressively harder level sequences.
- **Multi-level training loop:** Replace the hardcoded `DEFAULT_LEVEL_NAME = "1-14"` in `main_multiplayer.gd` with a loop through all levels.
- **Deterministic playback:** Ensure runs are deterministic so ghosts/bot replays can be recorded and raced against.

## Competition metrics

- **Distinct tiles touched:** Count unique grid cells the player collided with during a run.
- **Coverage reward:** Reward agents for crossing almost the entire map before finishing.
- **Exploration bonus:** Encourage visiting new tiles rather than optimizing only for time.

## Player-facing AI tools

- **Ghost race from trained agent:** Let the player race against a bot trained on the same level.
- **Training visualizer:** Show what the AI observes and why it chose an action.
- **Export trained agents:** Allow players to share ONNX models or bot replays.

## Workshop integrations

- **Headless evaluation mode:** Run many agents against a level and report rankings automatically.
- **Web leaderboard for AIs:** Separate leaderboard for bot times, distinct from human leaderboard.

## When to pursue

After V1.0 ships and the core game is stable. The ML workshop deadline drives the immediate `1-17` + distinct-tiles work only.