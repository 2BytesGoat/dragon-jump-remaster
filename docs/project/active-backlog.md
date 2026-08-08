---
title: Backlog
tags: [godot, game-engine, project-management, backlog, tasks]
related:
  - "[[project/current-sprint]]"
  - "[[project/decisions]]"
  - "[[design/release-plan]]"
  - "[[future/shelved-features]]"
  - "[[future/research-ideas]]"
search_terms: [backlog, tasks, bugs, features, cleanup, known-issues]
---

# Backlog

This backlog is ordered by priority. The rule is: **ship the reproducible arcade pipeline by Aug 31, then build the EA build (editor + Workshop + 25–30 levels) for a Dec 2026 Early Access launch.**

> **Aug 31 hard deadline:** Ship a documented Godot → web → Emulation Station → Switch pipeline that jam participants can replicate. The game is the test case — it needs to be *playable enough*, not polished. See [[design/release-plan]] § Release milestones.

> **Dec 2026 EA launch:** Editor + Workshop + 25–30 campaign levels + basic arcade + basic ML mode at $9.99. See the 2026-08-05 decision in [[project/decisions]].

## Phase 0 — Arcade pipeline (now → Aug 31, 2026)

### Sprint 1 — Minimal playable loop + CI verify (Aug 3 → Aug 17)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 52 | Fix arcade exit bug — mode-aware routing | `main.gd:183` `_on_exit_button_pressed()` hardcoded to level_select; arcade should go to `main_menu.tscn`, practice to `level_select.tscn` | High |
| 53 | Fix arcade "stuck at end" — no end screen shown | `main.gd:138` `_show_arcade_game_over()` is a no-op TODO; `main.gd:206` silent return on last level | High |
| 54 | Wire arcade game-over to reuse existing end_screen | Reuse `end.tscn` with arcade-appropriate text (score, Try Again / Exit); no new scene, no leaderboard | High |
| 67 | Verify CI web export produces a playable HTML5 build | `.github/workflows/build-and-publish.yml` already pushes to itch via butler; verify the web artifact boots and plays in a browser (boot, arcade mode, play, die, retry, exit) | High |
| 68 | Research: can Emulation Station on the modded Switch run an HTML5 web build at all? | CFW (SX OS / Atmosphere / RetroArch), browser core / standalone HTML5 loader options. Output: a yes/no + the specific launcher mechanism. Research only — ~1.5h. | High |

### Sprint 2 — Emulation Station + documentation + reproducibility test (Aug 17 → Aug 31)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 69 | Install Emulation Station on the modded Switch | Document the mod setup | High |
| 82 | Build scraper: fetch latest web build from itch.io and populate Emulation Station | Dev uploads to itch → scraper detects → pulls latest web build onto cabinet → ES shows it. Feasibility unknowns: itch.io API access for build downloads, where the scraper runs (on Switch? on a host? cron?), how ES discovers/launches the fetched build. Estimated ~8h for a prototype. **Depends on #68 confirming ES can run HTML5 at all.** | High |
| 70 | Configure Emulation Station to launch the web build | Browser core or standalone HTML5 loader | High |
| 71 | Test full cabinet boot flow | Power on → ES → game → play → exit → ES; repeated 3x without crash | High |
| 72 | Write reproducible pipeline documentation | Repo setup, CI config, export preset, ES setup, cabinet boot — so another dev can follow it | High |
| 73 | Second-dev reproducibility test | Follow only the docs, no shortcuts, replicate from scratch | High |
| 32 | Smoke-test arcade attract / game-over / restart loop | Must survive long exhibition days | High |
| 33 | Produce arcade build artifacts | Export and checksum the arcade binary | High |

### Pre-pipeline carryover (already done, kept for reference)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 30 | Final playtest all 17 campaign levels (`1-1` through `1-17`) | Ensure medals and unlocks feel right | High |
| 31 | [x] Build and verify arcade mode — logic skeleton only | Only `ArcadeDirector` logic shipped 2026-07-27/28; UI/end-flow incomplete — see #52–#54, #67–#73 | High |
| 34 | [x] Update top-level README for arcade + V1.0 scope | Cut promises about multiplayer/editor | High |

## Phase 1 — EA build (Sep → Nov 2026)

> Goal: the editor + Workshop + 25–30 campaign levels are the product. See [[design/release-plan]] § Early Access.

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 83 | Build the in-game level editor | Symbol-based format; reuses in-engine editor fixes from #49. **The core EA product.** | Critical |
| 84 | Steam Workshop integration | Publish/subscribe community levels. Depends on #83. | Critical |
| 85 | Organize campaign into worlds | 5 worlds, 6–8 levels + 1 boss each. Reorganize existing 17 levels into the world structure. | Critical |
| 86 | Level production: reach 25–30 campaign levels | At 2–3 levels/week. Fold in existing 1-1..1-17, design new levels to fill world gaps. | Critical |
| 87 | Boss level design (1 per world) | Longer, harder, tests all world mechanics; no powerup pickups inside. | High |
| 88 | World selection screen | Shows unlocked worlds, best score/medal/rank; locked worlds grayed out with theme preview. | High |
| 89 | Basic arcade mode with local leaderboard | Wire existing `ArcadeDirector` + end_screen; local top-10. | High |
| 90 | Basic ML training mode (visible, functional) | Un-hide from secret access; simple menu entry; "train AI on any level." | High |
| 91 | EA store page update | Screenshots, description, trailer, tags, EA honesty section ("EA has 25–30 levels + editor; 1.0 will add…"). | Critical |
| 92 | Tutorial / input clarity for casual players | Playtest feedback: players did not know the inputs. | High |
| 93 | Fill powerup gaps in campaign | Dash, Stomp, Grapple levels are missing from the current 17. | High |
| 9 | Remove or hide unused half-implemented systems | `MULTIPLAYER_LEVELS`, crown tile, progress bar, tag-mode code | Medium |

## Phase 2 — EA launch (Dec 2026)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 94 | EA launch on Steam at $9.99 | Under-promise on the store page; over-deliver. | Critical |
| 95 | Community management setup | Bug report channels, feedback pipeline, roadmap post. Solo-dev expectations set early. | High |
| 96 | Workshop moderation basics | Report system; add tools during EA based on what actually happens. | Medium |

## Phase 3 — 1.0 build (Jan → Jul 2027)

> Goal: world-based arcade, daily/weekly challenges, and full polish. See [[design/release-plan]] § 1.0 Launch.

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 97 | 10–15 additional campaign levels (total 35–40) | Complete world structure. | Critical |
| 98 | Daily challenge system | Procedural seeds + SilentWolf leaderboard; resets at midnight. | Critical |
| 99 | Weekly challenge system | Harder curated seed, Monday–Sunday; SilentWolf leaderboard. | Critical |
| 100 | World-based arcade with online leaderboards | Per-world score submission to SilentWolf. | Critical |
| 101 | Gauntlet mode | All worlds back-to-back, 5 lives; unlocks after all worlds cleared. | High |
| 102 | Steam leaderboards for campaign levels | Permanent per-level best times. | High |
| 103 | Full SFX and music | Source decision pending; budget freelance audio (~$500–2000). | High |
| 104 | UI overhaul | Premium look for $12.99. | High |
| 105 | ML starter code and tutorials (external blog) | Cross-promotion with the ML audience. | Medium |
| 55 | Arcade victory screen — clearing level 1-17 | "YOU DID IT!", final score, lives remaining, top-10 leaderboard | Medium |
| 56 | Heart pickup scene + scoring + pickup animation | `heart_pickup.tscn` + `.gd`; +1 life if <3, +500pts if full; auto-spawn in secret islands in arcade mode | Medium |
| 57 | Arcade HUD — integrate `arcade_hud.tscn` | Lives, score, level badge; planned (not built) — see [[technical/ui/arcade-hud]] | Medium |
| 58 | Local arcade top-10 leaderboard | Extend `GameData` with `arcade_top_runs: Array`; persist via SaveManager; display on game-over/victory screens | Medium |
| 74 | Inter-level score tracking + game juice | Ensure `ArcadeDirector.score` persists across level transitions; level-finish transition animation, score popup, screen shake | Medium |
| 75 | Hidden areas in remaining 11 levels | Levels 1-4, 1-5, 1-6, 1-7, 1-10, 1-11, 1-12, 1-13, 1-14, 1-15, 1-16 need M-tiles (level design, small chunks) | Medium |
| 23 | Screen shake | Juice/polish | Medium |
| 25 | Glow for portal | Level visual polish | Low |
| 26 | UI texture revamp | UI visual overhaul | Medium |
| 27 | Update duplicate level | Level design cleanup | Medium |
| 28 | Make CRT effect global + add toggleable setting | Settings / visual effect | Medium |
| 29 | Player outline as toggleable setting | Settings / visual effect | Medium |
| 59 | SilentWolf online leaderboard integration | Plugin review; submit_arcade_score when online; offline fallback to local top-10 | Low |
| 60 | Fix telemetry — level completion time not saved | Verify `TelemetrySystem.level_finished()` persists | Low |
| 76 | Replace tileset with Nico's tiles | Needs Nico tileset format decision | Medium |
| 77 | Arcade-feeling scene transition | Replace fade-in/fade-out; needs style decision | Low |
| 78 | Bounce-pad SFX + animation | Needs sound source decision | Low |
| 79 | Menu music + SFX | Needs music source decision | Low |
| 80 | Draft new menu layout mockup | Mood board + paper/digital mockup | Low |
| 81 | Weeds on ledges | Visual polish | Low |

### Juice plan items (tracked in [[project/game-juice-plan]], scheduled here)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| P0-1 | Celebrations are killed the same frame they start | Pause players, `await` 1.3s so the celebration plays, then advance | High |
| P0-2 | Split `arcade_rank_hud.reset()` | Level transitions reset timer/bar/band/score without killing celebration tweens | High |
| P0-3 | Hide score/multiplier outside arcade mode | Medal pace bar stays in practice; score does not | High |
| P1-1 | One centered pace cluster | Timer → medal bar → band label integrated | High |
| P1-2 | Band threshold ticks on the medal bar | See how close you are to losing your band | High |
| P1-3 | Enlarge top-right score + multiplier chip | Count-up and death-reset animations stay | Medium |
| P2-1 | Rank card shows both factors | Time multiplier × streak multiplier = total bonus | Medium |
| P2-2 | Unify streak formatting | `x%.2f` in HUD and game-over | Medium |
| P3-1 | Merge floating "+N" into the rank card | Drop the separate drifting label | Low |
| P3-2 | Fix NEW HIGH SCORE blink | Settle at a steady state instead of snapping back | Low |

## Phase 4 — Marketing (Apr → Jul 2027)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 106 | Steam page refresh | New trailer, screenshots, description, tags; the existing page has been inactive ~2 years. | Critical |
| 107 | Steam Next Fest demo | First 2 worlds + editor. | Critical |
| 108 | Streamer/press key distribution | Speedrun + ML YouTubers are the target audience. | High |
| 109 | Devlog series on Steam + external blog | Show editor workflow, level design, ML training. | Medium |
| 110 | Wishlist campaign | Target 10,000+ wishlists before 1.0 launch. | High |

## Phase 5 — 1.0 launch (Aug 2027)

| # | Task | Notes | Priority |
|---|------|-------|----------|
| 111 | 1.0 launch at $12.99 with 20% launch discount | Announce price increase during EA early. | Critical |
| 112 | Post-launch bug fixes | From EA community reports. | Critical |
| 113 | First post-launch content update | New world, 10–15 levels. | Medium |

## Done (kept for reference)

### Phase 1 — Hackathon prep (2026-07-25 sprint)

- [x] #1 Add level `1-17` for ML workshop — `Constants.LEVELS`, hidden from regular level-select, loadable by name for AI training.
- [x] #2 Add distinct-tiles-touched tracking — RL competition metric.
- [x] #3 Fix `MEDAL_NAMES` typo: `SIVLER` → `SILVER`.
- [x] #4 Fix `unlock_next_level` off-by-one guard in `SaveManager`.
- [x] #5 Verify end screen stats are correct.
- [x] #6 Verify main menu navigation works.
- [x] #7 Check for breaking bugs in main paths (menu → level → finish → retry → next level).
- [x] #8 Regression-test existing levels `1-1` through `1-16`.

### Foundation hardening (Phase 2, 2026-07-24 → 08-02)

- [x] #12 Rename `GaplingHook` / `gapling_hook.gd` → `GrapplingHook`.
- [x] #13 Fix `SceneManger` → `SceneManager` typo.
- [x] #14 Fix `emplased_time` → `elapsed_time` typo.
- [x] #15 Fix `preogress_bar` → `progress_bar` typo in end screen.
- [x] #16 Rename `CampaingLevelData` → `CampaignLevelData`.
- [x] #17 Remove duplicated `.gd` extension from `player_ai_training_controller.gd.gd`.
- [x] #18 Decide what to do with duplicate end screen files.
- [x] #22 Document `multiplayer_world.gd` (deleted — no longer needed).
- [x] #24 Grass blades — shipped 2026-08-01.
- [x] #47 Powerup card visual system — shipped 2026-07-31 to 2026-08-01.
- [x] #48 Parallax background system — shipped 2026-07-28.
- [x] #49 In-engine level editor fixes — PR #25 merged 2026-07-27.
- [x] #50 Telemetry system — shipped 2026-07-25.

### Other

- [x] #40 Secret areas in campaign levels — pulled forward and shipped 2026-07-29.

## Open decisions (needed soon)

- Switch mod setup details (SX OS, Atmosphere, RetroArch) — needed for Sprint 2 (#69–70)
- Preferred scene transition style — needed for #77
- Bounce-pad / menu music sound sources — needed for #78–79
- Daily/weekly challenge backend: SilentWolf vs. lightweight custom service — needed for #98–99
- Existing inactive Steam page: refresh in place vs. new app — needed for Phase 1 (#91)

## Research & experiments

See [[future/research-ideas]] for RL curriculum learning, multi-level training loops, deterministic playback, and player-facing AI tools. These stay in research until EA ships.

## Shelved indefinitely

See [[future/shelved-features]] for full descriptions of roguelike mode, crown/tag, co-op, chicken-horse, and full multiplayer.
