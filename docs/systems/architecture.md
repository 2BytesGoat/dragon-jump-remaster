# Architecture — Dragon Jump Remaster

**Scope:** V1.0 single-player arcade speedrun platformer.

## Target Autoloads (Singletons)

The approved V1.0 autoload roster is five core singletons. Two helper autoloads (`Constants`, `SignalBus`) remain for V1.0 hardening; they are documented here as transitional.

| Autoload | Responsibility |
|---|---|
| `SaveManager` | Persist settings, high scores, best times, and hidden AI telemetry. |
| `SceneLoader` | Own scene loading, transitions, and run-wide scene state. |
| `AudioManager` | Cross-scene music and global bus mixing only. Local one-shots live in scenes. |
| `Settings` | Global user preferences: volume, fullscreen, input remap. |
| `GameSession` | Ephemeral session state: current level, current seed, speed modifier, run flags. |
| `Constants` *(helper)* | Default player name and shared resource references only. Tunable data lives in `res://resources/`. |
| `SignalBus` *(helper)* | Cross-scene signals only (`new_run_attempt`, `new_time_submission`). |

| Static Class | Responsibility |
|---|---|
| `Utils` | Shared pure helpers: time formatting, Dijkstra map generation, name validation. No longer an autoload; use `Utils.method()`. |
| `CampaignLevelLibrary` | Loads all `CampaignLevelData` resources from `res://resources/level_data/`. |

## Data-Driven Design

Tunable values live in Godot Resource assets, not code:

| Resource | Holds |
|---|---|
| `PhysicsParams` | gravity, jump force, coyote time, terminal velocity |
| `LevelData` | per-player progress: attempts, best time, milestone, percentage |
| `CampaignLevelData` | symbol code, display name, medal times, hidden flag |
| `LevelCodeParser` | symbol-string parsing helper for `Level` |
| `PowerupPalette` | powerup colors/effects |
| `MedalConfig` | medal thresholds, colors |
| `AudioBusConfig` | bus volumes, snapshots |

## Scene Ownership

- Each scene owns its children.
- Cross-scene communication uses signals, not direct node references.
- Prefer composition over deep inheritance.

## Removed / Deferred for V1.0

- Multiplayer code and scenes
- Crown/tile-tag mode
- Progress-bar mode
- Duplicate/placeholder UI screens
- Online leaderboards (`LeaderboardManager` + `SilentWolf`) — deferred to post-launch
- `RuntimeSecrets` / `EnvironmentVariables` autoloads — folded into hidden AI training scene

## Hidden AI Training Mode

- Isolated from player-facing UI.
- Reaches `SaveManager` only through explicit save calls.
- Not referenced in marketing materials.
- Command-line argument parsing is local to the training scene.