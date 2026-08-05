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

## `design/` — Game Design Document

Product identity, vision, core loop, progression, release plan, and AI training mode design.

- [[design/product-identity]] — Elevator pitch and scope
- [[design/vision-and-goals]] — Long-term goals and project history
- [[design/core-loop]] — Gameplay loop, controls, powerups, medals
- [[design/progression-and-meta]] — Campaign structure, save data, medals
- [[design/release-plan]] — V1.0 scope lock, phases, milestones
- [[design/arcade-mode]] — Arcade build design (lives, scoring, game over)
- [[design/ai-training-mode]] — Hidden AI tinkerer feature

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
- [[technical/leaderboard]] — Leaderboard UI (V1.0 placeholder; online deferred)
- [[technical/rl-integration]] — Godot RL Agents addon integration
- [[technical/training]] — RL training infrastructure
- [[technical/utilities]] — Constants, SceneLoader, Utils static helpers

### `level-design/` — Level design rules and tooling

- [[level-design/design-rules]] — Extracted rules for World 1 (all 17 levels)
- [[level-design/design-rules-template]] — Template for extracting level-design rules
- [[level-design/editor-export-migration]] — In-editor level editing and code export notes

### `project/` — Project management

Sprints, backlog, decisions, code review, and refactor plans.

- [[project/current-sprint]] — Active sprint status
- [[project/active-backlog]] — Active task backlog (phases 1-6)
- [[project/decisions]] — Decision log
- [[project/master-checklist]] — Living refactor/release/commercialization checklist
- [[project/code-review]] — Code review issues and restructuring plan
- [[project/anti-piracy]] — Anti-piracy threat model and implementation plan
- [[project/repo-review]] — 2026-08-02 repository audit notes
- [[project/refactor-phase-1]] — Phase 1 refactor plan (complete)
- [[project/refactor-phase-2]] — Phase 2 refactor plan (complete)
- [[project/level-scripts-refactor]] — Level scene refactor summary
- [[project/secrets-note]] — GitHub secret requirements for HMAC save signing
- **Sprints:**
  - [[project/sprints/_template]] — Template for new sprint files
  - [[project/sprints/sprint-2026-07-25]] — ML Workshop Competition (completed)
  - [[project/sprints/sprint-2026-08-17]] — Sprint 1: Minimal playable arcade loop
  - [[project/sprints/sprint-2026-08-31]] — Sprint 2: Reproducible arcade pipeline

### `future/` — Future ideas (not in V1.0)

Shelved features, research ideas, and polish plans intentionally kept out of current scope.

- [[future/shelved-features]] — Features cut from V1.0 scope
- [[future/research-ideas]] — Future AI/RL research directions
- [[future/game-juice-plan]] — Game juice / reward-loop polish plan

### `meta/` — Documentation about documentation

- [[meta/process]] — How to write docs for this project (standards, workflow, template)
- [[meta/compliance-checklist]] — Doc quality checklist
- [[meta/tracking]] — File tracker (what's documented and what's not)

### `archive/` — Legacy content

- [[archive/project-notes]] — Legacy project notes (content split into `design/`, `project/`, `future/`)

---

Last restructured: 2026-08-05