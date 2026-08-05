Documents to create/update
1. docs/project/decisions.md — Append this entry
## 2026-08-05 — Editor-first pivot, Early Access, and commercial plan

**Context:** Strategic review against the goal of $100k+ first-year revenue. The handcrafted-levels positioning puts us against Celeste/Super Meat Boy. An editor-first identity puts us in an uncontested space (Mario Maker has no AI, Geometry Dash has no AI).

### Decisions

| # | Topic | Decision | Rationale |
|---|---|---|---|
| 1 | Product identity | **Editor-first.** The level editor + Workshop is the main value proposition. The handcrafted campaign teaches mechanics and demonstrates what good levels look like. | Competing on handcrafted levels alone is a losing battle against legendary games. Editor + Workshop + ML is an uncontested niche. |
| 2 | ML/AI mode | **Visible but not central.** Mentioned on store page. Starter code and tutorials on external blog. Not a separate product. | AI hype is a differentiator that gets coverage from ML YouTubers and workshop audiences. Building a full AI product is out of scope. |
| 3 | Launch strategy | **Early Access.** EA in Dec 2026 at $9.99. 1.0 in Aug 2027 at $12.99. | Editor-first games benefit from community content snowball. Two visibility bumps (EA + 1.0). Revenue starts in 4 months instead of 12. Editor gets battle-tested by real users before 1.0. |
| 4 | EA content | **25-30 campaign levels + editor + Workshop + basic arcade + basic ML mode.** | Enough to teach all mechanics and show what's possible. The editor is the infinite content engine. |
| 5 | 1.0 content | **35-40 campaign levels + world-based arcade + boss levels + daily/weekly challenges + full polish + ML tutorials.** | Substantial content bump justifies leaving EA and the price increase. |
| 6 | Price | **$9.99 EA, $12.99 1.0.** 20% launch discount at 1.0. Frequent 30-40% sales post-launch. | EA discount from full price is standard convention. Higher base anchors value; sales bring it into impulse-buy range. Can lower permanently later; can't raise. |
| 7 | Arcade mode | **World-based.** 5 worlds, each with 6-8 levels + 1 boss level. Pick a world → play all levels with 3 lives → score submitted to world leaderboard. "Gauntlet" mode unlocks after all worlds cleared. | Clear progression units. A world run is 5-10 minutes — perfect for "one more run." |
| 8 | Daily/weekly challenges | **Procedurally generated from seeds.** Daily: one seed, leaderboard resets at midnight. Weekly: harder curated seed, runs Monday-Sunday. | Retention engine. "Wordle effect" — players come back daily. |
| 9 | Leaderboard strategy | **Steam for campaign levels, SilentWolf for daily/weekly challenges and arcade.** | Steam leaderboards are permanent and prestigious. SilentWolf handles time-windowed queries without needing to clear leaderboards. |
| 10 | Workshop | **Launch feature (EA).** In-game level editor using symbol-based format. Steam Workshop for sharing/downloading. | This is the product. Ships day 1 of EA. |
| 11 | Roguelike mode | **Shelved.** | Daily/weekly challenges give the same "fresh run every day" retention without building a second game. |
| 12 | Multiplayer | **Shelved.** | Scope black hole. Playtesters didn't ask for it. |
2. docs/design/release-plan.md — Full rewrite
# Release Plan — Dragon Jump Remaster

**Version:** 1.0 (target Aug 2027)
**Price:** $9.99 Early Access, $12.99 full release, 20% launch-week discount
**Engine:** Godot 4.x

## Product Identity

Dragon Jump Remaster is an **editor-first speedrun platformer.** Players build, share, and compete on community levels via Steam Workshop. A 35-40 level handcrafted campaign teaches the mechanics. A visible ML training mode lets players train AI on any level.

## V1.0 Scope

### In V1.0
- In-game level editor using symbol-based format
- Steam Workshop integration for sharing/downloading levels
- 35-40 handcrafted campaign levels across 5 worlds
- World-based arcade mode (3 lives, boss levels, world leaderboards)
- Daily and weekly procedurally generated challenges
- Online leaderboards (Steam for campaign, SilentWolf for challenges/arcade)
- ML training mode (visible, with external starter code and tutorials)
- Windows, Linux, macOS, Web exports
- Gamepad support
- Full SFX, music, and UI polish

### Out of V1.0
- Multiplayer / networked play
- Roguelike mode
- Crown / tile-tag mode
- Mobile port

## Early Access (Dec 2026)

| What | Details |
|------|---------|
| Price | $9.99 |
| Campaign | 25-30 handcrafted levels |
| Editor | Full in-game level editor |
| Workshop | Level sharing and downloading |
| Arcade | Basic mode with local leaderboard |
| ML mode | Functional, basic, visible |
| Polish | Placeholder SFX, pre-polish UI |

## 1.0 Launch (Aug 2027)

| What | Details |
|------|---------|
| Price | $12.99 (20% launch discount) |
| Campaign | 35-40 levels across 5 worlds with boss levels |
| Arcade | World-based with online leaderboards (SilentWolf) |
| Challenges | Daily + weekly procedural challenges |
| ML mode | Polished, with external starter code and tutorials |
| Polish | Full SFX, music, UI overhaul |

## Phases

| Phase | When | Goal | Deliverable |
|-------|------|------|-------------|
| **0** | Now → Aug 31, 2026 | Arcade pipeline | Reproducible Godot → web → Emulation Station → Switch pipeline |
| **1** | Sep → Nov 2026 | EA build | Editor + Workshop + 25-30 campaign levels + basic arcade + basic ML |
| **2** | Dec 2026 | **EA launch** | Steam Early Access at $9.99 |
| **3** | Jan → Jul 2027 | 1.0 build | Remaining campaign levels, world-based arcade, daily/weekly challenges, polish, ML tutorials |
| **4** | Apr → Jul 2027 | Marketing | Steam page refresh, Next Fest demo, streamer outreach |
| **5** | Aug 2027 | **1.0 launch** | Full release at $12.99 |

## Release Sequence

1. **Early Access (Dec 2026)** — $9.99. Editor + Workshop + 25-30 levels. Start building the community content snowball.
2. **1.0 Launch (Aug 2027)** — $12.99. 35-40 levels + world-based arcade + daily/weekly challenges + full polish.

## Commercial Priorities

- Steam tags: Level Editor, Platformer, Speedrun, Arcade, 2D, Artificial Intelligence
- Trailer under 60 seconds showing: build a level → share it → play community levels → train AI
- Devlogs on Steam community and external blog
- ML starter code and tutorials on external blog (cross-promotion)
- Steam Next Fest demo (first 2 worlds + editor)
3. docs/design/product-identity.md — Rewrite the elevator pitch and scope sections
Replace lines 14-29 with:
> **Dragon Jump Remaster is an editor-first speedrun platformer. Players build, share, and compete on community levels via Steam Workshop. A handcrafted campaign teaches the mechanics. A visible ML training mode lets players train AI on any level.**

## What the player gets

- A robust in-game level editor using a simple symbol-based format.
- Steam Workshop integration — build, share, download, and compete on community levels.
- A 35-40 level handcrafted campaign across 5 worlds that teaches all mechanics.
- World-based arcade mode with boss levels and online leaderboards.
- Daily and weekly procedurally generated challenges.
- ML training mode for tinkerers — train AI on any level, including community creations.

## What is not the focus (for V1.0)

- Online multiplayer.
- Roguelike mode.
- Co-op / bot race.
- FunRun-style crown/tag mode.
- Chicken-horse mode.
- Mobile port.

These are shelved experiments documented in `[[future/shelved-features]]`.
4. docs/project/active-backlog.md — Reorganize phases
Replace the phase structure with:
## Phase 0 — Arcade pipeline (now → Aug 31, 2026)

> Unchanged. See current sprint.

## Phase 1 — EA build (Sep → Nov 2026)

| # | Task | Priority |
|---|------|----------|
| 1 | In-game level editor (symbol-based) | Critical |
| 2 | Steam Workshop integration | Critical |
| 3 | 25-30 campaign levels across 5 worlds | Critical |
| 4 | World-based arcade mode (basic, local leaderboard) | High |
| 5 | Basic ML training mode (functional, visible) | High |
| 6 | World selection screen | High |
| 7 | Boss level design (1 per world) | High |
| 8 | EA store page update (screenshots, description, trailer) | High |

## Phase 2 — EA launch (Dec 2026)

| # | Task | Priority |
|---|------|----------|
| 9 | EA launch on Steam at $9.99 | Critical |
| 10 | Community management setup (bug reports, feedback channels) | High |
| 11 | Workshop moderation tools (basic) | Medium |

## Phase 3 — 1.0 build (Jan → Jul 2027)

| # | Task | Priority |
|---|------|----------|
| 12 | 10-15 additional campaign levels (total 35-40) | Critical |
| 13 | Daily challenge system (procedural seeds, SilentWolf leaderboard) | Critical |
| 14 | Weekly challenge system (curated seeds, SilentWolf leaderboard) | Critical |
| 15 | World-based arcade with online leaderboards (SilentWolf) | Critical |
| 16 | Gauntlet mode (all worlds back-to-back) | High |
| 17 | Steam leaderboards for campaign levels | High |
| 18 | Full SFX and music | High |
| 19 | UI overhaul (premium look) | High |
| 20 | ML starter code and tutorials (external blog) | Medium |
| 21 | Polish: screen shake, portal glow, CRT toggle, player outline toggle | Medium |
| 22 | Secret areas in all campaign levels | Medium |

## Phase 4 — Marketing (Apr → Jul 2027)

| # | Task | Priority |
|---|------|----------|
| 23 | Steam page refresh (new trailer, screenshots, description) | Critical |
| 24 | Steam Next Fest demo (first 2 worlds + editor) | Critical |
| 25 | Streamer/press key distribution | High |
| 26 | Devlog series on Steam + external blog | Medium |

## Phase 5 — 1.0 launch (Aug 2027)

| # | Task | Priority |
|---|------|----------|
| 27 | 1.0 launch at $12.99 with 20% launch discount | Critical |
| 28 | Post-launch bug fixes | Critical |
| 29 | First content update (new world, 10-15 levels) | Medium |

## Shelved

See [[future/shelved-features]] for roguelike mode, multiplayer, crown/tag, chicken-horse, and mobile port.
5. docs/future/shelved-features.md — Add roguelike to shelved indefinitely
Add to the "Shelved indefinitely" section:
- [ ] **Roguelike mode:** Procedural chained levels with permadeath, meta-progression, and daily seeds.
  - Shelved 2026-08-05. Daily/weekly challenges provide the same "fresh run every day" retention without building an entirely new game loop.
6. docs/design/core-loop.md — Add editor loop
Add after the "One-sentence loop" section:
## Editor loop

Open editor → place tiles with symbol-based format → test the level → publish to Workshop → community plays and competes → iterate based on feedback.
7. docs/design/progression-and-meta.md — Update for world-based structure
Replace the "Campaign structure" section:
## Campaign structure

The game ships with 35-40 handcrafted levels across 5 themed worlds. Each world has 6-8 regular levels and 1 boss level.

- Worlds unlock sequentially (beat world N to unlock world N+1).
- Levels within a world unlock sequentially.
- The player can replay any unlocked level at any time.
- Each level tracks attempts, best time, and medal progress.
- Boss levels test mastery of all mechanics from that world.

## Arcade structure

- Pick a world → play all its levels with 3 lives → score submitted to world leaderboard.
- Hidden extra lives behind `M` secret tiles.
- "Gauntlet" mode unlocks after all worlds cleared (all worlds back-to-back, 5 lives).
That's the complete plan. Someone can now write these into the docs. The key changes from the current docs:
1. Product identity shifts from "speedrun game with hidden AI" to "editor-first platformer with ML differentiator"
2. Price goes from $4.99 to $9.99 EA / $12.99 1.0
3. Launch strategy adds Early Access in Dec 2026
4. Campaign shrinks from 100 to 35-40 (editor is the content engine)
5. Arcade becomes world-based with boss levels
6. Daily/weekly challenges added as retention engine
7. Roguelike explicitly shelved
8. ML mode moves from hidden to visible (but not central)