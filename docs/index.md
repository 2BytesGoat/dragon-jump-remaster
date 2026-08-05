---
title: Dragon Jump Remaster — Docs Vault
tags: [godot, game-engine, index, docs, vault]
related:
  - "[[getting-started]]"
  - "[[design/product-identity]]"
  - "[[project/current-sprint]]"
  - "[[project/active-backlog]]"
  - "[[technical/architecture]]"
search_terms: [index, vault, docs, dragon-jump-remaster, navigation, home]
---

# Dragon Jump Remaster — Docs Vault

Full directory of every doc in the vault, organized by area.

> **New to the project?** Start with [[getting-started]] — a 5-minute orientation guide.

## What do you want to do?

| Task | Read these in order |
|------|---------------------|
| Understand the game | [[design/product-identity]] → [[design/core-loop]] |
| See the big picture | [[design/vision-and-goals]] → [[design/release-plan]] |
| Understand the codebase | [[technical/architecture]] → [[technical/main-system]] |
| See what's being worked on now | [[project/current-sprint]] (goal) → [[project/sprints/sprint-2026-08-17]] (full plan + status) |
| Pick up a task | [[project/active-backlog]] |
| Review past decisions | [[project/decisions]] |
| Check if X is in EA/1.0 scope | [[future/shelved-features]] → [[future/research-ideas]] |
| Plan polish work | [[project/game-juice-plan]] → [[future/shelved-features]] |
| Work on levels | [[technical/level-system/index]] → [[level-design/design-rules]] |
| Change save/load | [[technical/save-system/index]] |
| Add or modify UI | [[technical/ui/index]] |
| Work on effects | [[technical/effects]] |
| Work on powerups | [[technical/powerups]] |
| Understand the event bus | [[technical/signal-bus]] |
| Write or update docs | [[meta/process]] |
| Find closed/historical work | [[archive/project-notes]] (legacy) · [[archive/repo-review]] · [[archive/refactor-phase-1]] · [[archive/refactor-phase-2]] · [[archive/level-scripts-refactor]] |

---

## `design/` — Game Design Document

Product identity, vision, core loop, progression, release plan, and AI training mode design.

- [[design/product-identity]] — Elevator pitch and scope
- [[design/vision-and-goals]] — Long-term goals and project history
- [[design/core-loop]] — Gameplay loop, controls, powerups, medals
- [[design/progression-and-meta]] — Campaign structure, save data, medals
- [[design/release-plan]] — EA (Dec 2026) + 1.0 (Aug 2027) phases and milestones
- [[design/arcade-mode]] — Arcade build design (lives, scoring, game over)
- [[design/ai-training-mode]] — ML training mode (visible, not central)

### `technical/` — Technical reference

Per-system documentation for every code system and scene.

- [[technical/architecture]] — Autoload roster, data-driven design, scene ownership
- [[technical/main-system]] — Core game loop orchestrator (`main.gd`, `main.tscn`)
- [[technical/player-system]] — Player character, state machine, controllers
- [[technical/level-system/index]] — Tile-based level system
  - [[technical/level-system/wall-blend]] — Wall blend visual effect
  - [[technical/level-system/secrets-layer]] — Hidden secret areas
  - [[technical/level-system/background]] — Dynamic background rendering
  - [[technical/level-system/terrain-layer]] — Terrain tile management
- [[technical/save-system/index]] — SaveManager singleton and data resources
  - [[technical/save-system/level-data]] — Per-level progress resource
  - [[technical/save-system/campaign-level-data]] — Campaign level definition resource
  - [[technical/save-system/game-data]] — Top-level save data resource
- [[technical/ui/index]] — Main menu and end screen
  - [[technical/ui/arcade-hud]] — Arcade HUD integration draft
- [[technical/effects]] — Visual/audio effects (particles, smoke)
- [[technical/powerups]] — Powerup collectibles and card UI
- [[technical/signal-bus]] — Centralized event bus singleton
- [[technical/leaderboard]] — Leaderboard UI (EA placeholder; Steam + SilentWolf at 1.0)
- [[technical/rl-integration]] — Godot RL Agents addon integration
- [[technical/training]] — RL training infrastructure
- [[technical/utilities]] — Constants, SceneLoader, Utils static helpers

### `level-design/` — Level design rules and tooling

- [[level-design/design-rules]] — Extracted rules for World 1 (all 17 levels)
- [[level-design/design-rules-template]] — Template for extracting level-design rules
- [[level-design/editor-export-migration]] — In-editor level editing and code export notes

### `project/` — Project management

#### Active workflow

- [[project/current-sprint]] — Current sprint goal (epic-level entry point; links to the full sprint file)
- [[project/active-backlog]] — Active task backlog (Phase 0 pipeline → Phase 5 1.0 launch)
- [[project/decisions]] — Decision log
- [[project/game-juice-plan]] — Reward-loop polish plan with P0/P1/P2/P3 work items
- [[project/master-checklist]] — Living refactor/release/commercialization checklist

**Sprints:**
- [[project/sprints/_template]] — Template for new sprint files
- [[project/sprints/sprint-2026-07-25]] — ML Workshop Competition (completed)
- [[project/sprints/sprint-2026-08-17]] — Sprint 1: Minimal playable arcade loop **(active)**
- [[project/sprints/sprint-2026-08-31]] — Sprint 2: Reproducible arcade pipeline
- [[project/sprints/sprint-2026-09-30]] — EA Sprint 1: Editor foundation + world reorganization
- [[project/sprints/sprint-2026-10-31]] — EA Sprint 2: Workshop + arcade + boss levels
- [[project/sprints/sprint-2026-11-30]] — EA Sprint 3: EA build complete + store prep
- [[project/sprints/sprint-2026-12-15]] — EA launch (Dec 2026, $9.99)

#### Reference

- [[project/anti-piracy]] — Anti-piracy threat model and implementation plan
- [[project/code-review]] — Code review issues and restructuring plan
- [[project/secrets-note]] — GitHub secret requirements for HMAC save signing

> Closed/historical project docs (refactor phases, repo review, level-scripts refactor) have moved to [[#`archive/` — Legacy content]].

### `future/` — Future ideas (not in EA/1.0)

> **When to read this:** consult when asking "is X in EA/1.0 scope?" or planning post-1.0 work. Active polish work with concrete tasks lives in [[project/game-juice-plan]], not here.

- [[future/shelved-features]] — Features cut from scope (and a "Pulled forward" record of what got unshelved and shipped)
- [[future/research-ideas]] — Future AI/RL research directions

### `meta/` — Documentation about documentation

- [[meta/process]] — How to write docs for this project (standards, workflow, template)
- [[meta/compliance-checklist]] — Doc quality checklist
- [[meta/tracking]] — File tracker (what's documented and what's not)

### `archive/` — Legacy content

Historical and closed docs. Kept to avoid breaking old links; do not add new content here.

- [[archive/project-notes]] — Legacy project notes (content split into `design/`, `project/`, `future/`)
- [[archive/repo-review]] — 2026-08-02 repository audit notes
- [[archive/refactor-phase-1]] — Phase 1 refactor plan (complete)
- [[archive/refactor-phase-2]] — Phase 2 refactor plan (complete)
- [[archive/level-scripts-refactor]] — Level scene refactor summary

---

Last restructured: 2026-08-05