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

> **Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.**

## What the player gets

- A tight, single-button campaign of hand-authored speedrun levels.
- Instant restart, muscle-memory gameplay, medal chasing.
- Optional hidden AI training mode for tinkerers and workshop participants.

## What is not the focus (for V1.0)

- Online multiplayer.
- Map editor.
- Co-op / bot race.
- FunRun-style crown/tag mode.
- Chicken-horse mode.

These are shelved experiments documented in `[[future/shelved-features]]`.

## Platform identity

| Build | Primary goal | Notes |
|-------|--------------|-------|
| Steam / itch.io | Sell a small, coherent speedrun game | Hidden AI mode as a value-add |
| Arcade machine | Icebreaker for the author's gamedev community | Possibly simpler menu, no online leaderboard |
| Research / ML workshop | Training environment for RL agents | Same build, launched with a flag or hidden menu |

## Guiding principle

> The goal is not to make a perfect game. The goal is to finish a small, coherent game and learn from releasing it.