# Release Plan — Dragon Jump Remaster

**Version:** 1.0-locked (2026-07-24)  
**Price target:** $4.99 USD, 10–20% launch-week discount  
**Engine:** Godot 4.x (version pinned during Phase 1)

## V1.0 Scope Lock

The first commercial release is a **single-player arcade speedrun platformer**.

### In V1.0
- Single-button arcade speedrun loop
- 10–20 handcrafted levels using the symbol-based level system
- Local high score / best-time tracking (via SaveManager)
- Title → level select / endless mode → run → death/retry → score screen
- Windows, Linux, macOS, Web exports
- Gamepad support (post-launch if time does not allow)

### Out of V1.0
- Multiplayer / networked play (deleted)
- Crown / tile-tag mode (deleted)
- Progress-bar mode (deleted)
- AI training mode (kept hidden, not marketed)
- Online leaderboards (post-launch)
- Level editor UI for players (post-launch)

## Phases

| Phase | Goal | Duration | Deliverable |
|---|---|---|---|
| **0** | Scope lock + file audit | 1–2 weeks | Locked backlog, architecture doc updated |
| **1** | Foundation hardening | 3–4 weeks | Clean base, no dead code, autoloads shrunk |
| **2** | Arcade vertical slice | 2–3 weeks | Playable arcade build ready for testing |
| **3** | Platform + store prep | 2–3 weeks | Steam/itch pages, export pipeline, beta |
| **4** | Launch + learn | 1–2 weeks + ongoing | Arcade demo → paid launch → post-mortem |

## Release Sequence

1. **Free arcade build / demo** — ship first to validate feel, gather wishlists, and provide press/streamers a vertical slice.
2. **Paid Steam + itch.io release** — launch after the arcade build proves the loop and generates wishlists.

## Commercial Priorities

- Trailer/GIF under 30 seconds showing the single-button loop.
- Steam tags: Arcade, Platformer, Speedrun, Single-button, Retro, 2D.
- Devlogs on itch.io and Steam community.
- Local leaderboard for V1.0; online leaderboards later.

## Open Questions

- Exact Godot version pin (decided in Phase 1).
- Launch discount percentage (10% vs 20%).
- Whether Web demo ships before or alongside desktop arcade build.
