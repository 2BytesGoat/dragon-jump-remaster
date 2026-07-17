---
title: Shelved Features
tags: [godot, game-engine, backlog, shelved, future, scope]
related:
  - "[[direction/release_plan]]"
  - "[[direction/product_identity]]"
  - "[[tracking/backlog]]"
search_terms: [shelved, future, multiplayer, editor, crown, tag, chicken-horse, arcade, secrets, procedural]
---

# Shelved Features

These features are intentionally **not part of V1.0**. They are kept visible so they do not creep back into scope silently.

## V1.1 candidates (post-ship, depends on player feedback)

- **More campaign levels**
  - Target: 25+ total levels.
  - Current gap: levels specifically designed for Dash, Stomp, and Grapple powerups.
  - Depends on: clean level tooling and a solid level design workflow.

- **Secret areas**
  - Hidden routes and collectibles similar to *Neon White*.
  - Adds replayability to sub-5-second speedrun levels.
  - Requires: secret tile (`M`) mechanics already exist, but level design needs to intentionally use them.

- **Map editor**
  - In-game editor using the existing symbol-based format.
  - QR-code level sharing: generate a QR from a level code, edit on a phone, import back into the game.
  - Steam Workshop integration for sharing levels.
  - Big feature; only worth building if players are asking for it.

- **Procedural / weekly levels**
  - Randomly generated maps for weekly events.
  - Good for retention, but requires deterministic generation and balance tuning.

## V1.2+ / platform-specific

- **Arcade mode**
  - Limited-lives system (3 lives by default).
  - Hidden extra lives behind `M` secret tiles.
  - QR code pointing to the Steam full release so arcade players can buy it.
  - This is the post-ship arcade build identity.

## Shelved indefinitely unless explicitly revived

- **Co-op / bot race:** Race against a friend or a recorded bot ghost.
- **FunRun crown/tag mode:** Grab a crown and race back to the end; crown can be stolen on reset.
  - Existing code: crown tile, progress bar, `MULTIPLAYER_LEVELS` dictionary.
  - These are currently wired but not exposed in the player-facing loop.
- **Chicken-horse mode:** Players edit the level between rounds.
- **Full online multiplayer** beyond SilentWolf leaderboards.

## When to revive

Only after V1.0 is shipped and the author has learned from player feedback. The decision to revive any of these must be explicit and written in `[[tracking/decisions]]`.