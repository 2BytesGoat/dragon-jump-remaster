# Release Plan — Dragon Jump Remaster

**Version:** 1.0 (target Aug 2027)
**Price:** $9.99 Early Access, $12.99 full release, 20% launch-week discount
**Engine:** Godot 4.x (version pinned during Phase 1)

## Product Identity

> Dragon Jump Remaster is an **editor-first speedrun platformer.** Players build, share, and compete on community levels via Steam Workshop. A handcrafted campaign teaches the mechanics. A visible ML training mode lets players train AI on any level.

See [[design/product-identity]] and the 2026-08-05 decision in [[project/decisions]].

## V1.0 Scope

### In V1.0
- In-game level editor using the symbol-based level format
- Steam Workshop integration for sharing / downloading levels
- 35–40 handcrafted campaign levels across 5 worlds (6–8 levels + 1 boss level each)
- World-based arcade mode (3 lives, boss levels, world leaderboards)
- Daily and weekly procedurally generated challenges
- Online leaderboards (Steam for campaign, SilentWolf for challenges/arcade)
- ML training mode (visible, with external starter code and tutorials)
- Windows, Linux, macOS, Web exports
- Gamepad support

### Out of V1.0
- Multiplayer / networked play
- Roguelike mode
- Crown / tile-tag mode
- Mobile port

## Early Access (Dec 2026)

| What | Details |
|------|---------|
| Price | $9.99 |
| Campaign | 25–30 handcrafted levels |
| Editor | Full in-game level editor |
| Workshop | Level sharing and downloading |
| Arcade | Basic mode with local leaderboard |
| ML mode | Functional, basic, visible |
| Polish | Placeholder SFX, pre-polish UI |

## 1.0 Launch (Aug 2027)

| What | Details |
|------|---------|
| Price | $12.99 (20% launch discount) |
| Campaign | 35–40 levels across 5 worlds with boss levels |
| Arcade | World-based with online leaderboards (SilentWolf) |
| Challenges | Daily + weekly procedural challenges |
| ML mode | Polished, with external starter code and tutorials |
| Polish | Full SFX, music, UI overhaul |

## Phases

| Phase | When | Goal | Deliverable |
|-------|------|------|-------------|
| **0** | Now → 2026-08-31 | Arcade pipeline | Reproducible Godot → web → Emulation Station → Switch pipeline |
| **1** | Sep → Nov 2026 | EA build | Editor + Workshop + 25–30 campaign levels + basic arcade + basic ML |
| **2** | Dec 2026 | **EA launch** | Steam Early Access at $9.99 |
| **3** | Jan → Jul 2027 | 1.0 build | Remaining campaign levels, world-based arcade, daily/weekly challenges, polish, ML tutorials |
| **4** | Apr → Jul 2027 | Marketing | Steam page refresh, Next Fest demo, streamer outreach |
| **5** | Aug 2027 | **1.0 launch** | Full release at $12.99 |

## Release milestones

Each milestone has a target date and the sprints that feed it. Update dates here when they slip (and note the slip in [[project/decisions]]). To plan the next release, read this table top-to-bottom and slice the next sprint from the first unfinished milestone's phase.

| Milestone | Phase | Target date | Sprints | Status |
|---|---|---|---|---|
| Reproducible arcade pipeline | 0 | **2026-08-31** (hard deadline; September away, Oct game jam) | [[project/sprints/sprint-2026-08-17]] (Sprint 1) + [[project/sprints/sprint-2026-08-31]] (Sprint 2) | In progress — logic skeleton shipped, pipeline work starting |
| EA build complete | 1 | **2026-11-30** | [[project/sprints/sprint-2026-09-30]] + [[project/sprints/sprint-2026-10-31]] + [[project/sprints/sprint-2026-11-30]] | Not started |
| Early Access launch (paid) | 2 | **2026-12-15** | [[project/sprints/sprint-2026-12-15]] (EA launch sprint) | Not started |
| 1.0 build complete | 3 | **2027-07-31** | TBD | Not started |
| Steam V1.0 launch (paid) | 5 | **2027-08-31** | TBD | Not started |

### Aug 31 pipeline roadmap (2-sprint crunch)

| Sprint | Window | Focus | Deliverables |
|---|---|---|---|
| Sprint 1 | Aug 3 → Aug 17 | Minimal playable loop + CI verify | #52 exit bug, #53 stuck-at-end, #54 reuse end_screen, #67 CI web export, #68 ES research |
| Sprint 2 | Aug 17 → Aug 31 | Emulation Station + docs + reproducibility | #69 ES install, #70 ES config, #71 boot flow test, #72 pipeline docs, #73 second-dev test |

> **Primary goal:** Ship a documented Godot → web → Emulation Station → Switch pipeline that October jam participants can replicate. The game is the test case — it needs to be *playable enough*, not polished. Game polish (hearts, hidden areas, HUD, leaderboard, juice) is deferred to Phase 3.

> Sprints live in `docs/project/sprints/`. See [[meta/process]] § Sprint workflow for the cadence and capacity-budget rules.

## Release Sequence

1. **Early Access (Dec 2026)** — $9.99. Editor + Workshop + 25–30 levels. Start building the community content snowball.
2. **1.0 Launch (Aug 2027)** — $12.99. 35–40 levels + world-based arcade + daily/weekly challenges + full polish.

## Commercial Priorities

- Steam tags: Level Editor, Platformer, Speedrun, Arcade, 2D, Artificial Intelligence
- Trailer under 60 seconds showing: build a level → share it → play community levels → train AI
- Devlogs on Steam community and external blog
- ML starter code and tutorials on external blog (cross-promotion)
- Steam Next Fest demo (first 2 worlds + editor)

## Open Questions

- Whether the Oct game jam affects EA build timeline (jam month = low level-production capacity).
- Whether the daily/weekly challenge backend is SilentWolf or a lightweight custom service.
- Steam Workshop technical approach (Godot Workshop integration plugin vs. custom Steamworks wrapper).
- Whether the existing inactive Steam page needs a full refresh or a new app.
