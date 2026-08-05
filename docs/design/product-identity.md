---
title: Product Identity
tags: [godot, game-engine, gdd, product-identity, scope, direction]
related:
  - "[[design/vision-and-goals]]"
  - "[[design/core-loop]]"
  - "[[design/release-plan]]"
  - "[[project/decisions]]"
search_terms: [product-identity, elevator-pitch, target-audience, core-experience, scope]
---

# Product Identity

> **Dragon Jump Remaster is an editor-first speedrun platformer. Players build, share, and compete on community levels via Steam Workshop. A handcrafted campaign teaches the mechanics. A visible ML training mode lets players train AI on any level.**

## What the player gets

- A robust in-game level editor using a simple symbol-based format.
- Steam Workshop integration — build, share, download, and compete on community levels.
- A 35–40 level handcrafted campaign across 5 worlds that teaches all mechanics.
- World-based arcade mode with boss levels and online leaderboards.
- Daily and weekly procedurally generated challenges.
- ML training mode for tinkerers — train AI on any level, including community creations.

## What is not the focus (for V1.0)

- Online multiplayer.
- Roguelike mode.
- Co-op / bot race.
- FunRun-style crown/tag mode.
- Chicken-horse mode.
- Mobile port.

These are shelved experiments documented in `[[future/shelved-features]]`.

## Platform identity

| Build | Primary goal | Notes |
|-------|--------------|-------|
| Steam / itch.io | Sell an editor-first speedrun game with community content | ML training mode as a marketed differentiator |
| Arcade machine | Icebreaker for the author's gamedev community | Possibly simpler menu, no online leaderboard |
| Research / ML workshop | Training environment for RL agents | Same build, launched with a flag or hidden menu |

## Guiding principle

> The goal is not to make a perfect game. The goal is to finish a small, coherent game and learn from releasing it.

See the 2026-08-05 pivot in `[[project/decisions]]` for the editor-first strategy and pricing rationale.