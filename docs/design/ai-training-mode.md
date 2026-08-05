# AI Training Mode — Dragon Jump Remaster

**Status:** Visible but not central (2026-08-05 decision, [[project/decisions]]). Mentioned on the store page; starter code and tutorials on an external blog. **Not** a separate AI-development product.

## Purpose

A mode that lets technically curious players (and the developer) train reinforcement-learning agents on Dragon Jump levels — including community-created Workshop levels. It is a differentiator (AI hype, ML YouTubers, workshop audiences), not the main product.

## Visibility Rules

- **EA (Dec 2026):** basic, functional, visible — a menu entry that launches training on any level.
- **1.0 (Aug 2027):** polished, with external starter code and tutorials (blog/external sources).
- Never a separate product or an AI-development tool; the editor is the product.

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

- Whether to publish a separate educational repo with stripped-down systems.
