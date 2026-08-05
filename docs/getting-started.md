---
title: Getting Started
tags: [onboarding, newcomer, guide, orientation]
related:
  - "[[design/product-identity]]"
  - "[[design/core-loop]]"
  - "[[technical/architecture]]"
  - "[[project/current-sprint]]"
  - "[[index]]"
search_terms: [getting-started, onboarding, newcomer, orientation, where-to-start, intro]
---

# Getting Started

New to the project? This guide will orient you in 5 minutes.

## What is Dragon Jump Remaster?

An editor-first single-button speedrun platformer with a visible ML training mode. Players build and share levels via Steam Workshop. The plan is Early Access (Dec 2026, $9.99) then 1.0 (Aug 2027, $12.99). Read [[design/product-identity]] for the full pitch.

## How does it play?

One button. Auto-running dragon. Speedrun through hand-crafted levels (25–30 at Early Access, 35–40 at 1.0). Get medals (Bronze/Silver/Gold). Build and share your own levels via Workshop. See [[design/core-loop]] for the full gameplay loop.

## How is the code organized?

The project is a Godot 4 game. Key architecture decisions:
- **8 autoloads** (SaveManager, SceneLoader, AudioManager, Settings, GameSession, ArcadeDirector, TelemetrySystem, SignalBus) — see [[technical/architecture]]
- **Data-driven design** — tunable values live in Resource assets, not hardcoded
- **State machine** drives the player character — see [[technical/player-system]]
- **Symbol-based level definition** — levels are encoded as compact text codes — see [[technical/level-system/index]]

## Where do I start reading?

| If you want to... | Read this |
|--------------------|-----------|
| Understand the game | [[design/product-identity]] → [[design/core-loop]] |
| Understand the codebase | [[technical/architecture]] → [[technical/main-system]] |
| See what's being worked on | [[project/current-sprint]] (goal) → the linked sprint file (full plan + status) |
| Pick up a task | [[project/active-backlog]] |

For the full task-based navigation matrix (UI, save, levels, effects, scope checks, historical work), see [[index]].

## How is the docs vault organized?

```
docs/
├── index.md              ← Start here (full navigation hub)
├── getting-started.md    ← This file
├── design/               ← Game design documents (GDD)
├── technical/            ← Technical reference (one file per system)
├── level-design/         ← Level design rules and tooling
├── project/              ← Active workflow (sprints, backlog, decisions, juice plan)
├── future/               ← Shelved features and research ideas (out-of-scope checks)
├── meta/                 ← Documentation about documentation
└── archive/              ← Legacy and closed docs (refactor phases, repo review, project notes)
```

## How do sprints work?

2-week sprints with capacity-aware planning. See [[meta/process]] § Sprint workflow for the full cadence. Current sprint goal: [[project/current-sprint]] — full plan and status live in the linked sprint file.

## Tools

- `tools/visualize_levels.py` — Python script that decodes level codes into ASCII grids for visual reference. Run `python3 tools/visualize_levels.py` to print all levels, or pass a level name (e.g., `1-1`) for a specific one.