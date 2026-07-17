---
title: Release Plan
tags: [godot, game-engine, gdd, release-plan, v1.0, scope, milestones]
related:
  - "[[direction/product_identity]]"
  - "[[direction/vision_and_goals]]"
  - "[[direction/progression_and_meta]]"
  - "[[tracking/backlog]]"
  - "[[backlog/shelved_features]]"
search_terms: [release-plan, v1.0, scope, milestones, steam, arcade, ship]
---

# Release Plan

## Guiding principle

> **Fix what blocks now, harden the foundation, ship the arcade build, then prepare Steam. Big ideas come only after the core game is stable and released.**

The goal is not to build the perfect game in one release. The goal is to ship a small, coherent game that can support the ideas in `[[backlog/shelved_features]]` without collapsing under unused systems.

## Phases

| Phase | Goal | Details |
|-------|------|---------|
| Phase 1 | Hackathon prep and quick bugfixes | ML workshop competition on July 25, 2026. Add `1-17`, distinct-tiles tracking, fix critical bugs. |
| Phase 2 | Harden the foundation | Clean up unused systems, fix typos, move constants, document fragile code. |
| Phase 3 | Verify all 17 levels and ship arcade | Arcade build is already done; playtest all levels and ship the arcade binary ASAP. |
| Phase 4 | Steam release prep | Finalize Steam build, store page, deadline, and AI training mode delivery. |
| Phase 5 | Post-Steam features | Only after real player feedback; see `[[backlog/shelved_features]]` and `[[backlog/research_ideas]]`. |

## Phase 1 — Hackathon prep and quick bugfixes

The immediate target is the ML workshop final competition on **July 25, 2026**.

- Add level `1-17` to `Constants.LEVELS` with medal times.
- Record distinct tiles touched by the player for the competition metric.
- Fix critical typos and guards (`SIVLER`, `unlock_next_level` off-by-one, etc.).
- Verify no breaking bugs in the main paths and no regressions in levels `1-1` through `1-16`.

Full sprint plan: `[[tracking/sprints/sprint_2026_07_25]]`.

## Phase 2 — Harden the foundation

Before shipping anything publicly, make the codebase robust:

- Remove or hide unused half-implemented systems (`MULTIPLAYER_LEVELS`, crown tile, progress bar, tag-mode code).
- Fix naming/typo debt (`GaplingHook`, `SceneManger`, `emplased_time`, `preogress_bar`, `CampaingLevelData`, duplicated file extensions).
- Move magic numbers into `Constants`.
- Document fragile code (custom synchronizer, `multiplayer_world.gd`).

See `[[tracking/backlog]]#phase-2--harden-the-foundation`.

## Phase 3 — Verify all 17 levels and ship arcade

The arcade build is already functional. The goal here is to verify it and ship fast:

- Final playtest of all 17 campaign levels (`1-1` through `1-17`).
- Verify arcade mode: limited lives, `M` tiles giving extra lives, QR code pointing to Steam.
- Smoke-test the attract / game-over / restart loop for exhibition durability.
- Produce and checksum the arcade build artifacts.
- Update the README to describe the arcade build accurately.

See `[[tracking/backlog]]#phase-3--verify-all-17-levels-and-ship-arcade`.

## Phase 4 — Steam release prep

Once the arcade build is shipped, the next milestone is the Steam/itch.io release (~$5):

- Decide exact V1.0 release deadline and write it in `[[tracking/decisions]]`.
- Decide how the AI training mode is delivered (hidden menu vs separate build/launch flag).
- Complete Steam build checklist: store page, builds, playtest branch, leaderboards.
- Update README for the Steam scope.

See `[[tracking/backlog]]#phase-4--steam-release-prep`.

## Phase 5 — Post-Steam (only after real player feedback)

Potential directions, in no particular order:

- Secret areas, ghost race, map editor + QR sharing, more campaign levels, procedural/weekly levels, Steam Workshop.
- Research directions from `[[backlog/research_ideas]]` (RL improvements, competition metrics, player-facing AI tools).

Nothing here is committed until Steam ships and player feedback exists.

## Open decisions

All decisions must be recorded in `[[tracking/decisions]]` once made:

- [ ] Exact Steam release deadline for V1.0.
- [ ] AI training mode delivery: hidden menu, separate build, or launch flag.
- [ ] Desired level count for the first public Steam build.

## External deadlines

- **ML workshop final competition: July 25, 2026.** Details and sprint plan: `[[tracking/sprints/sprint_2026_07_25]]`.
