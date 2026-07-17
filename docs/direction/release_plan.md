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

> **Foundation first. Ship a small, coherent V1.0. Add features only after real player feedback.**

The goal is not to build the perfect game in one release. The goal is to build a clean foundation that can support the ideas in `[[backlog/shelved_features]]` without collapsing under unused systems.

## Phases

| Phase | Goal | Details |
|-------|------|---------|
| Phase 0 | Foundation cleanup | See `[[tracking/backlog]]#phase-0--foundation-cleanup` |
| Phase 1 | Ship V1.0 | See details below |
| Phase 2 | Post-V1.0 features | Depends on player feedback; see `[[tracking/backlog]]#phase-2--post-v10` |
| Phase 3 | Platform-specific builds | Arcade mode, Steam Workshop; see `[[tracking/backlog]]#phase-3--platform-specific` |

## Phase 1 — V1.0 ship

The smallest shippable version of the agreed product identity:

> **Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.**

### Must ship

- [ ] 16 existing campaign levels, playable from start to finish.
- [ ] Single-button speedrun gameplay (auto-run, jump/reset).
- [ ] Save system: attempts, best times, medals, level unlocks.
- [ ] Main menu, level select, pause screen, end screen.
- [ ] Basic sound and effects already in the project.

### Should ship

- [ ] Level `1-17` and distinct-tiles-touched tracking for the ML workshop competition. See `[[tracking/sprints/sprint_2026_07_25]]`.
- [ ] Clean foundation (Phase 0 complete).
- [ ] Correct end screen stats.
- [ ] Working main menu navigation.

### Could ship

- [ ] Levels specifically designed for Dash, Stomp, and Grapple powerups.
- [ ] Ghost race mode.

### Will not ship

All post-V1.0 features are documented in `[[backlog/shelved_features]]`.

## Open decisions

- [ ] Steam release first, arcade machine first, or both at the same time?
- [ ] Is the AI training mode a hidden menu in the same build, or a separate build/launch flag?
- [ ] What is the exact release deadline for V1.0?
- [ ] What is the desired level count for the first public build?

## External deadlines

- **ML workshop final competition: next week.** Details and sprint plan: `[[tracking/sprints/sprint_2026_07_25]]`.