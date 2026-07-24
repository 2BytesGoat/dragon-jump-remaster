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

## V1.0 (shipping now)

- **Single-player campaign** — 17 short hand-authored speedrun levels.
- **Local high score / save progress** — medals, attempts, best times.
- **Hidden AI training mode** — accessible only via undocumented input or launch flag.

See [[direction/release_plan]] for the full V1.0 plan.

## V1.1 candidates (post-ship, depends on player feedback)

- **More campaign levels**
  - Target: 25+ total levels.
  - Current gap: levels specifically designed for Dash, Stomp, and Grapple powerups.
  - Depends on: clean level tooling and a solid level design workflow.
  - **Strongest post-ship signal from playtesting:** this was the most common player request.

- **Secret areas**
  - Hidden routes and collectibles similar to *Neon White*.
  - Adds replayability to sub-5-second speedrun levels.
  - Requires: secret tile (`M`) mechanics already exist, but level design needs to intentionally use them.

## V1.2+ / platform-specific

- **Arcade exhibition mode**
  - Limited-lives system (3 lives by default).
  - Hidden extra lives behind `M` secret tiles.
  - QR code pointing to the Steam full release so arcade players can buy it.
  - This is a post-V1.0 build variant, not the first release.

- **Map editor**
  - In-game editor using the existing symbol-based format.
  - QR-code level sharing: generate a QR from a level code, edit on a phone, import back into the game.
  - Steam Workshop integration for sharing levels.
  - Big feature; only worth building if players are asking for it.

- **Procedural / weekly levels**
  - Randomly generated maps for weekly events.
  - Good for retention, but requires deterministic generation and balance tuning.

- **Phone-as-controller local multiplayer (Jackbox-style)**
  - The host game runs a local web server / LAN session.
  - Players join with a phone browser and use touch as a one-button controller.
  - Spectators can watch on the main screen without buying the game.
  - Useful for parties, exhibitions, and viral local sessions.
  - Big architecture change: network discovery, web input client, spectator UI, latency handling.
  - Only viable after Steam ships and the core loop is locked.

## Shelved indefinitely unless explicitly revived

- **Co-op / bot race:** Race against a friend or a recorded bot ghost.
- **FunRun crown/tag mode:** Grab a crown and race back to the end; crown can be stolen on reset.
  - Existing code was removed during V1.0 foundation hardening: crown tile, progress bar, `MULTIPLAYER_LEVELS` dictionary, tag-mode code.
  - To revive this, the feature must be rebuilt from the clean V1.0 base and explicitly approved in [[tracking/decisions]].
- **Chicken-horse mode:** Players edit the level between rounds.
- **Full online multiplayer** beyond SilentWolf leaderboards.

## When to revive

Only after V1.0 is shipped and the author has learned from player feedback. The decision to revive any of these must be explicit and written in [[tracking/decisions]].
