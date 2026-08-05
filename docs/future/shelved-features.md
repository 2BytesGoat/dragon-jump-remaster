---
title: Shelved Features
tags: [godot, game-engine, backlog, shelved, future, scope]
related:
  - "[[design/release-plan]]"
  - "[[design/product-identity]]"
  - "[[project/active-backlog]]"
search_terms: [shelved, future, multiplayer, editor, crown, tag, chicken-horse, arcade, secrets, procedural, tcg, cards, steam, marketplace, meta, retention]
---

# Shelved Features

These features are intentionally **not part of V1.0**. They are kept visible so they do not creep back into scope silently. Items that were originally shelved but got pulled forward and shipped are tracked in the **Pulled forward** section so we know how far we've got.

## Pulled forward (originally shelved, now done)

- [x] **Secret areas** (was V1.1 candidate)
  - Hidden routes and collectibles similar to *Neon White*.
  - Shipped 2026-07-29. Uses the existing `M` secret tile mechanic.
  - Hidden areas still need to be added to 11 remaining campaign levels (#75, Phase 3).
- [x] **Arcade exhibition mode — logic skeleton** (was V1.2+)
  - 3-lives system, `ArcadeDirector` autoload, per-level checkpoints.
  - Shipped 2026-07-27/28. UI/end-flow still in progress (current sprint #52–#54).
- [x] **Powerup card visual system**
  - Card art, draw animations, dissolve-on-use, pickup animations.
  - Shipped 2026-07-31 to 2026-08-01.
- [x] **Parallax background system**
  - Clunky → polished parallax backgrounds.
  - Shipped 2026-07-28.
- [x] **Grass blades / vines**
  - Level visual polish — grass tiles, vines, procedural grass shader.
  - Shipped 2026-08-01.
- [x] **Telemetry system**
  - Local analytics autoload.
  - Shipped 2026-07-25 (see [[technical/architecture]]).
- [x] **In-engine level editor fixes**
  - PR #25 merged 2026-07-27.

## EA / 1.0 (shipping now)

- [x] **Single-player campaign** — 17 short hand-authored speedrun levels (being reorganized into 5 worlds; expanding to 25–30 for EA, 35–40 for 1.0).
- [x] **Local high score / save progress** — medals, attempts, best times.
- [x] **Hidden AI training mode** — accessible only via undocumented input or launch flag (being surfaced as a visible EA feature per 2026-08-05 decision).

See [[design/release-plan]] for the full EA / 1.0 plan.

## V1.1 candidates (post-ship, depends on player feedback)

- [ ] **More campaign levels**
  - Target: 50+ total levels (35–40 ships at 1.0; this candidate covers post-1.0 expansions).
  - Current gap: levels specifically designed for Dash, Stomp, and Grapple powerups.
  - Depends on: clean level tooling and a solid level design workflow.
  - **Strongest post-ship signal from playtesting:** this was the most common player request.

## V1.2+ / platform-specific

- [ ] **Arcade exhibition mode — full build** (logic skeleton done, UI/end-flow in progress)
  - Limited-lives system (3 lives by default).
  - Hidden extra lives behind `M` secret tiles.
  - QR code pointing to the Steam full release so arcade players can buy it.
  - This is a post-V1.0 build variant, not the first release.
- [ ] **QR-code level sharing (editor extension)**
  - In-game editor ships with EA (see [[design/release-plan]]). QR-code sharing would let players generate a QR from a level code, edit on a phone, import back into the game — a V1.1 candidate on top of the shipped editor.
  - Steam Workshop integration is the V1.0 path for sharing levels.
- [ ] **Procedural level generation for campaign** (daily/weekly challenges are V1.0, see [[design/release-plan]])
  - Randomly generated maps for weekly events beyond the seeded challenge system — e.g. an endless mode.
  - The seed-based daily/weekly challenge system (V1.0, backlog #98–99) is the first procedural step; a full endless mode would build on that determinism work.
- [ ] **Phone-as-controller local multiplayer (Jackbox-style)**
  - The host game runs a local web server / LAN session.
  - Players join with a phone browser and use touch as a one-button controller.
  - Spectators can watch on the main screen without buying the game.
  - Useful for parties, exhibitions, and viral local sessions.
  - Big architecture change: network discovery, web input client, spectator UI, latency handling.
  - Only viable after Steam ships and the core loop is locked.

## Meta / retention (post-launch only)

- [ ] **TCG-style collectibles**
  - Players collect points during runs.
  - Points can be spent to open card packs.
  - Card packs drop cosmetic powerup card skins for the game.
  - Skins are linked to Steam inventory items.
  - Items can be sold on the Steam Marketplace.

## Shelved indefinitely unless explicitly revived

- [ ] **Roguelike mode**
  - Procedural chained levels with permadeath, meta-progression, item pools, and daily seeds.
  - Shelved 2026-08-05 (decision #11 in [[project/decisions]]). Daily/weekly challenges provide the same "fresh run every day" retention without building an entirely new game loop.
- [ ] **Co-op / bot race:** Race against a friend or a recorded bot ghost.
- [ ] **FunRun crown/tag mode:** Grab a crown and race back to the end; crown can be stolen on reset.
  - Existing code was removed during V1.0 foundation hardening: crown tile, progress bar, `MULTIPLAYER_LEVELS` dictionary, tag-mode code.
  - To revive this, the feature must be rebuilt from the clean V1.0 base and explicitly approved in [[project/decisions]].
- [ ] **Chicken-horse mode:** Players edit the level between rounds.
- [ ] **Full online multiplayer** beyond SilentWolf leaderboards.

## Engineering / tooling improvements

- [ ] **Level code compression**
  - Current format: `symbol+count` RLE per row, `|` separated (e.g. `W32|W5E21W6`). Already ~7-10x compression vs raw grid.
  - Goal: shorter level codes so players can share them more easily (chat, social, QR).
  - Short-term wins (low effort, can do now):
    - **Row deduplication** — `*` = repeat previous row, `*N` = repeat N times. ~15-20% savings on levels with repeated rows.
    - **Base-36 counts** — encode numbers as `0-9A-Z` instead of decimal. ~30% savings on number chars at the cost of readability.
  - Long-term (needs 100+ maps corpus):
    - **Macro block dictionary** — mine common rectangular sub-patterns across all levels, ship a pattern library with the game, encode levels as `!pattern_id@x,y` references + fallback RLE for unique parts. Best compression but requires a pattern discovery algorithm.
  - Depends on: larger level corpus before the dictionary approach is worth the complexity. See `src/scenes/level/level.gd` (`get_level_code`) and `src/scripts/resources/level_code_parser.gd` for the current encoder/decoder.

## When to revive

Only after V1.0 is shipped and the author has learned from player feedback. The decision to revive any of these must be explicit and written in [[project/decisions]].