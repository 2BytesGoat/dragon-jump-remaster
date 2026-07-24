# Architecture — Dragon Jump Remaster

**Scope:** V1.0 single-player arcade speedrun platformer.

## Target Autoloads (Singletons)

Only these five autoloads are allowed in V1.0. Scene-local concerns must live in scenes or Resource files.

| Autoload | Responsibility |
|---|---|
| `SaveManager` | Persist settings, high scores, best times, and hidden AI telemetry. |
| `SceneManager` | Own scene loading, transitions, and run-wide scene state. |
| `AudioManager` | Cross-scene music and global bus mixing only. Local one-shots live in scenes. |
| `Settings` | Global user preferences: volume, fullscreen, input remap. |
| `GameSession` | Ephemeral session state: current score, current seed, run flags. |

## Data-Driven Design

Tunable values live in Godot Resource assets, not code:

| Resource | Holds |
|---|---|
| `PhysicsParams` | gravity, jump force, coyote time, terminal velocity |
| `LevelData` | symbol code, name, medal times, music track, hidden flag |
| `PowerupPalette` | powerup colors/effects |
| `MedalConfig` | medal thresholds, colors |
| `AudioBusConfig` | bus volumes, snapshots |

## Scene Ownership

- Each scene owns its children.
- Cross-scene communication uses signals, not direct node references.
- Prefer composition over deep inheritance.

## Removed for V1.0

- Multiplayer code and scenes
- Crown/tile-tag mode
- Progress-bar mode
- Duplicate/placeholder UI screens

## Hidden AI Training Mode

- Isolated from player-facing UI.
- Reaches SaveManager only through explicit save calls.
- Not referenced in marketing materials.
