# Architecture — Dragon Jump Remaster

**Scope:** V1.0 single-player arcade speedrun platformer.

## Target Autoloads (Singletons)

The approved V1.0 autoload roster is eight autoloads: seven core singletons plus the transitional `SignalBus` helper. `Constants` and `Utils` are static classes, not autoloads.

| Autoload | Responsibility |
|---|---|
| `SaveManager` | Persist settings, high scores, best times, and hidden AI telemetry. |
| `SceneLoader` | Own scene loading, transitions, and run-wide scene state. |
| `AudioManager` | Cross-scene music and global bus mixing only. Local one-shots live in scenes. |
| `Settings` | Global user preferences: volume, fullscreen, input remap. |
| `GameSession` | Ephemeral session state: current level, current seed, speed modifier, run flags. |
| `ArcadeDirector` | Arcade mode setup, life tracking, run progression, and run summary for the local arcade leaderboard. |
| `TelemetrySystem` | Lightweight analytics abstraction; events log locally in debug builds. |
| `SignalBus` *(helper)* | Cross-scene signals only (`new_run_attempt`, `new_time_submission`). |

| Static Class | Responsibility |
|---|---|
| `Constants` | Default player name and shared resource references only. Tunable data lives in `res://resources/`. Call via `Constants.DEFAULT_PLAYER_NAME`; not an autoload. |
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
- Online leaderboards (`LeaderboardManager` + `SilentWolf`) — deferred to 1.0 build (Phase 3, 2027); EA ships with local leaderboards only
- `MonetizationSystem` — removed; no IAP/ad backend planned for V1.0
- `RuntimeSecrets` — build-time-only template (`runtime_secrets.gd.template`); copied to a gitignored `runtime_secrets.gd` and optionally registered as an autoload by the build pipeline when injecting the real HMAC secret

## Hidden AI Training Mode

- Isolated from player-facing UI.
- Reaches `SaveManager` only through explicit save calls.
- Not referenced in marketing materials.
- Command-line argument parsing is local to the training scene.