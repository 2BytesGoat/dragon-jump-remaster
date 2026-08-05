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

An arcade-style single-button speedrun platformer with a hidden AI training mode. The goal is to ship a free arcade build first, then a paid Steam/itch.io release. Read [[design/product-identity]] for the full pitch.

## How does it play?

One button. Auto-running dragon. Speedrun through 17 hand-crafted levels. Get medals (Bronze/Silver/Gold). See [[design/core-loop]] for the full gameplay loop.

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