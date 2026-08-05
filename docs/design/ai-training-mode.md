# AI Training Mode — Dragon Jump Remaster

**Status:** Hidden tinkerer feature. **Not** part of the player-facing V1.0 release.

## Purpose

A hidden mode that lets technically curious players (and the developer) train reinforcement-learning agents on Dragon Jump levels. It is a long-term value-add, not the main product.

## Visibility Rules

- Not shown in any menu.
- Not mentioned in marketing, store pages, trailers, or press materials.
- Accessible only through an undocumented input sequence or a launch flag.

## Technical Isolation

- AI controller lives in `src/scenes/player/controller/` alongside the human controller.
- All telemetry, snapshots, and save data flow through `SaveManager` only.
- No AI logic runs in the main menu or arcade loop unless explicitly activated.
- No network calls, no external services, no cloud uploads.

## Data Collection

- Local only.
- Per-run metrics: time, deaths, powerups used, finish flag.
- Stored in user save directory, not sent anywhere.

## Future Decisions

- Whether to expose a hidden "watch AI" screen after V1.0.
- Whether to publish a separate educational repo with stripped-down systems.
