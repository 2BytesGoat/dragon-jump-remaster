# AGENTS.md

Guidance for AI coding assistants working in this repository.

## Start here

Before reading code, read the docs. The docs vault is the source of truth for architecture, design decisions, and system behavior.

- **`docs/getting-started.md`** — 5-minute orientation
- **`docs/index.md`** — full vault directory (every doc, organized by area)

## If you're asked to...

| Task type | Read these docs first |
|-----------|----------------------|
| Understand the game | `docs/design/product-identity` → `docs/design/core-loop` |
| Understand the architecture | `docs/technical/architecture` |
| Modify gameplay / player | `docs/design/core-loop` → `docs/technical/player-system` |
| Work on levels | `docs/technical/level-system/index` → `docs/level-design/design-rules` |
| Change save/load | `docs/technical/save-system/index` |
| Add or modify UI | `docs/technical/ui/index` |
| Work on effects | `docs/technical/effects` |
| Work on powerups | `docs/technical/powerups` |
| Understand the event bus | `docs/technical/signal-bus` |
| Pick up a task | `docs/project/current-sprint` → `docs/project/active-backlog` |
| Make a design decision | `docs/project/decisions` → `docs/design/release-plan` |
| Check what's out of scope | `docs/future/shelved-features` |
| Write or update docs | `docs/meta/process` |

## Always update docs when making changes

When you modify code, update the corresponding documentation:

1. Update the relevant file in `docs/technical/` to reflect your changes.
2. Update `docs/meta/tracking.md` if you added or removed a source file, or changed its documentation status.
3. If your change affects a design decision, add an entry to `docs/project/decisions.md`.

Docs that are out of sync with code are worse than no docs — they mislead the next reader.

## Conventions

- **Engine:** Godot 4.x, GDScript
- **Doc filenames:** kebab-case (e.g., `player-system.md`)
- **Wikilinks:** full paths (`[[technical/player-system]]`, not `[[player_system]]`)
- **Autoloads (8):** SaveManager, SceneLoader, AudioManager, Settings, GameSession, ArcadeDirector, TelemetrySystem, SignalBus
- **Static classes:** Constants, Utils, CampaignLevelLibrary (not autoloads)
- **Data-driven design:** tunable values live in Resource assets under `res://resources/`, not hardcoded
- **State machine** drives the player character
- **Levels are symbol-based:** encoded as compact text codes, parsed at runtime

## Key paths

```
project.godot              — Godot project entry point
src/scenes/                — game scenes (player, level, effects, powerups, training)
src/scripts/singletons/    — autoloads
src/scripts/resources/     — data resources
src/scripts/components/    — reusable components (state machine, command pattern)
src/ui/                    — UI menus and components
src/tests/                 — test scenes
docs/                      — documentation vault
tools/visualize_levels.py  — level code decoder (prints ASCII grids)
```

## Don't run tests

The Godot executable path differs across machines. Do not run `run_tests.sh` or attempt to launch Godot from the command line. If tests need to be run, ask the user to do it.