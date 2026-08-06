# Decision Log — Dragon Jump Remaster

This document captures high-level decisions as the project evolves.

---

## 2026-08-06 — Run timer owns its clock (no HUD-owned timing)

**Context:** The run timer lived inside the `ArcadeRankHud` scene (`single_time_container.gd`), and `main.gd` reached across scenes to call `track_player()` on it. The `time_container` export was never wired in `main.tscn`, producing a Nil crash — a symptom of the timer being gameplay state stranded in a UI scene.

- **Decided the clock is a dedicated `RunTimer` component** (`src/scripts/components/run_timer.gd`, `class_name RunTimer`) at the **Main root** of `main.tscn`. It owns `total_time`, race gating, player-signal wiring, and session-time flushing to `SignalBus.play_time_elapsed`. It is the single source of truth for run time.
- **The HUD timer is display-only:** `single_time_container.gd` became `src/ui/components/time_display.gd` (`class_name TimeDisplay`) — a label fed by `RunTimer.time_changed` → `set_time()`. No clock state, no player references, no signals in the UI.
- **Dependency direction is now `main → HUD`:** `main.gd` wires the player to the timer (`run_timer.track_player()`), hands the timer to the HUD (`arcade_rank_hud.run_timer = run_timer`), and the HUD only *reads* `run_timer.total_time` / `race_started` for medal-pace visuals.
- **Fixed a latent bug:** practice-mode finish submitted main's own `total_time`, which was never set (always `0.0`); it now submits `run_timer.total_time`.
- **Deleted the stale draft** `src/ui/components/arcade_rank_hud.tscn` (referenced a removed script).

---

## 2026-08-06 — Main menu start-flow animation

**Context:** The revamped main menu (`src/ui/menus/main_menu.tscn`) needed a title-screen moment before the button column, matching the arcade-mode "Pulsing PRESS JUMP TO START" pillar ([[design/arcade-mode]]).

- **Decided the title screen shows a blinking "Press JUMP to Start" label** next to a `PlayerMock` (the real player sprite, idle frame) that, on `player_one_jump` input, switches to the jump frame and arcs off-screen along the **real jump physics** (jump gravity to peak, then fall gravity — same constants as `PhysicsParams`), fading out as it leaves the bottom of the screen.
- **The jump plays the same SFX as the in-game jump** (`swoosh.ogg` on the SFX bus, `-12 dB`), via a local `JumpSFX` `AudioStreamPlayer` — one-shots live in scenes, per the AudioManager convention.
- **After the mock leaves the screen**, the start container hides, the selection container fades in, and focus moves to the Play button.
- **The mock is freed from container layout** (`top_level = true`) during the arc so the tween can move it freely; the arc is computed analytically per frame (no per-frame velocity accumulation in a lambda).
- **Play button wired to the game scene:** `_on_play_button_pressed()` calls `ArcadeDirector.start_arcade_run()` then `SceneLoader.go_to("res://main.tscn")`, mirroring the old menu's play flow. Practice/Create/Quit remain unwired for now.

---

## 2026-08-06 — Reusable BonusPopup component

**Context:** The "+bonus" level-clear popup was a single Label hard-coded inside `ArcadeRankHud`, animated in place. Future secret-area bonuses (backlog item #56) would need the same popup in multiple places simultaneously.

- **Decided the bonus popup is a reusable, one-shot component** (`BonusPopup`, `src/ui/components/bonus_popup.gd/.tscn`) that spawns above a world position and frees itself — not a single recycled label. Concurrent bonuses stack because each spawn is independent.
- **Tuning lives in one shared place:** `resources/bonus_popup_config.tres` (drift / pop-in / fade-out / lifetime / position-offset), matching the "tunable values live in Resource assets" convention.
- **Scoring stays with the caller:** `ArcadeDirector` was not touched (only `level_rank_awarded`-independent scoring); the HUD owns the rank→color mapping, and `main.gd` feeds the player's finish position in via `pending_popup_world_position` (relies on `on_level_finished()` emitting synchronously).
- **The HUD root is in the `"GameplayHud"` group** so world-side callers can spawn via `BonusPopup.find_hud()` without a hard scene reference.

---

## 2026-08-06 — Retention time counts all active play

**Context:** The stats screen's "time played" counters (total/daily/weekly) were only incremented on level finish, so time spent on failed runs and restarts was lost, understating real play time.

- **Decided that "time played" counts all active run time**, including deaths and restarts, not just completed runs. The run timer now accumulates a session total that survives restarts and is flushed to `SignalBus.play_time_elapsed`, which SaveManager adds to the retention counters.
- **Active time only:** pre-first-jump reading time and paused time are excluded, matching how clear times are measured.
- **Best-time/leaderboard semantics unchanged:** `new_time_submission` no longer feeds the retention counters (it only handles best time, progress, and unlocks), avoiding double counting.

---

## 2026-07-17 — Product identity and early scope

- **Refined product identity** to:

  > Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.

  Details: [[design/product-identity]].

- **Decided V1.0 scope** is the polished 16-level speedrun campaign, with AI training as a hidden/tinkerer value-add. Multiplayer, crown/tag, editor, and chicken-horse are shelved.

- **Identified the upcoming ML workshop competition** as the immediate external deadline. Sprint plan: [[project/sprints/sprint-2026-07-25]].

- **Status update:** The `1-17` level and distinct-tiles-touched tracking are **not yet implemented** in code, despite an earlier note claiming they were added. They remain the top priority for the current sprint.

- **Recorded playtesting feedback:**
  - Most common request: **more levels**. This becomes the strongest signal for the first post-ship feature.
  - Mobile was suggested repeatedly, but the author explicitly does not want to pursue it now; it stays shelved.
  - "Too fast" feedback was addressed by adding a speed slider.
  - **No tutorial / unclear inputs** was flagged as a barrier, especially for casual players. This needs to be fixed before shipping.
  - Nobody asked for multiplayer, ghost race, editor, or other fancy features. The author's excitement is not player demand; those stay shelved.
  - **Nuance on "more levels":** players kept going because short levels feel low-commitment, but some were discouraged when the top leaderboard gap was large. The request for "more" may partly be a request for more *substance* per session, not just more count.

- **Decided to keep short levels as the core format.** FunRun-style long levels with random powerups would change the product identity. The short-level format supports low-commitment retries, clear leaderboards, and fast AI playtesting. Post-ship level design can explore a few slightly longer or mixed-length curated levels, but the core stays short and hand-authored.

- **Clarified the core hook:** the game is a collection of short, interesting speedrun problems that players can hop on and off of. The hook is not one long adventure or random powerup chaos; it is the low-commitment retry loop, the hand-authored level design, and the chase for a better time.

- **Decided source/IP strategy:** the main Dragon Jump repo will be made private before commercial release to protect the full game, levels, and assets. After release, the author may publish a separate educational repo with core architecture and systems (no assets, no levels, no branding) under a permissive license, similar to the Aseprite model. The commercial value is the official build, updates, leaderboards, and community — not code secrecy. Technical or legal protection alone cannot stop a determined bad actor; the defense is being the trusted official version.

---

## 2026-07-24 — V1.0 Scope Lock and Foundation Approvals

**Approved by:** solo developer  
**Context:** Foundation cleanup and release planning.

### Decisions

| # | Topic | Decision | Rationale |
|---|---|---|---|
| 1 | Multiplayer | **Removed for V1.0.** All multiplayer files deleted. | Outside single-player arcade scope; adds coupling and network risk. |
| 2 | Crown / tile-tag mode | **Removed for V1.0.** | Half-implemented; confuses scope. |
| 3 | Progress-bar mode | **Removed for V1.0.** | Can be rebuilt cleanly from a solid base if needed later. |
| 4 | AI training mode | **Kept hidden.** Accessible only via secret input/launch flag. | Value-add for tinkerers; never marketed. |
| 5 | Symbol-based level editor | **Kept.** | Core content pipeline. |
| 6 | Autoloads | **Five approved:** `SaveManager`, `SceneLoader`, `AudioManager`, `Settings`, `GameSession`. `Constants` and `SignalBus` remain as documented transitional helper autoloads for V1.0 hardening; `Utils` is now a static `class_name` helper and is no longer an autoload. | Avoid fragile global state while preserving existing signal bus and const utilities. |
| 7 | Release order | **Free arcade build first, then paid Steam/itch.io.** | Validate loop and build wishlists before charging. |
| 8 | V1.0 content | 10–20 handcrafted levels, local high score, endless/survival mode. | Small, shippable, learnable. |
| 9 | Price | **$4.99 USD** with 10–20% launch-week discount. | Matches small-arcade market. |
| 10 | Involvement model | Developer decides/reviews; AI executes code changes; developer tests builds. | Fits solo dev with limited bandwidth. |

### Shader compiler warning (2026-07-24)

- **Symptom:** Headless smoke test logged `ERROR: Condition "!actions.custom_samplers.has(function->arguments[j].tex_builtin)" is true. Continuing.`
- **Cause:** `assets/shaders/powerup.gdshader` passed the built-in `TEXTURE` sampler into a custom `tex(sampler2D, vec2)` helper. Godot 4.x flags this pattern internally.
- **Fix:** Inlined the UV-bounds guard with a preprocessor macro (`SAFE_TEXTURE`) so `TEXTURE` is sampled directly inside `fragment()`, not passed through a function.
- **Status:** Resolved; smoke test now passes without shader warnings.

### Renames

| Old | New | Status |
|---|---|---|
| `SceneManger` / `scene_manger.gd` | `SceneLoader` / `scene_loader.gd` | Done (superseded; see backlog #13) |
| `emplased_time` | `elapsed_time` | Done (then removed as dead) |

### Removed files

- `src/scenes/training/main_multiplayer.gd`
- `src/scenes/training/main_multiplayer.tscn`
- `src/scenes/training/multiplayer_world.gd`
- `src/scenes/training/multiplayer_world.tscn`
- `main_multiplayer` button from `main_menu.tscn`

### 2026-07-24 — Deferred systems

- **LeaderboardManager + SilentWolf:** Deferred to post-launch. The UI leaderboard component now shows "Leaderboard disabled in V1.0." Online scores will be re-enabled once backend integration is solid.
- **RuntimeSecrets / EnvironmentVariables:** Removed from autoloads. Environment parsing is now local to the hidden AI training scene; SilentWolf secrets are no longer needed while online leaderboards are deferred.

### Open questions

- Exact Godot 4.x patch version to pin.
- Launch discount percentage (10% vs 20%).
- Web demo timing (before or alongside desktop demo).
- Gamepad support for V1.0 or post-launch.

---

## 2026-08-02 — Autoload roster amendment

**Context:** During Phase 1 foundation hardening, the autoload roster grew beyond the five originally approved on 2026-07-24.

- **Current V1.0 autoloads (8):** `SignalBus`, `SceneLoader`, `SaveManager`, `AudioManager`, `Settings`, `GameSession`, `ArcadeDirector`, `TelemetrySystem`.
- **What changed:** `SignalBus` remained as a transitional helper autoload; `ArcadeDirector` was added for arcade run state; `TelemetrySystem` was added for local analytics.
- **What stayed out:** `Constants` and `Utils` are static classes, not autoloads. `RuntimeSecrets` is build-time-only. `MonetizationSystem` remains removed.
- **Source of truth:** [[technical/architecture]].

## 2026-08-04 — Arcade reward-loop juice (Tier 1)

**Context:** Playtest feedback and self-review: the game's *gameplay* juice (shake, hit stop, wipe, cards) is strong, but the *reward loop* has no dopamine — score swaps instantly, no SFX on clear/rank/death, no floating score popups, no clear flash.

- **Decided to implement Tier 1 reward juice now** (see [[project/game-juice-plan]]): score count-up roll, floating "+N" popup on clear, rank-colored screen flash on clear, medal-bar pulse on band change, and placeholder SFX for clear/gold/death using the existing asset pool.
- **Deferred Tier 2** (streak milestone celebrations, gold confetti, game-over screen juice) and **Tier 3** (menu button hover, best-streak stat, timer tension tick) — they stay in the juice plan doc, not the backlog, until Tier 1 is playtested.
- **SFX sourcing is the open question:** real clear/gold/death sounds need a source decision before Tier 1 sound is final. Placeholders are `SoundBonus.wav` / `SoundSlide.wav`.

---

## 2026-08-05 — Editor-first pivot, Early Access, and commercial plan

**Context:** Strategic review against the goal of $100k+ first-year revenue. Competing on handcrafted levels alone puts the game against Celeste / Super Meat Boy / VVVVVV. An editor-first identity puts it in a near-uncontested space (Mario Maker has no AI; Geometry Dash has no AI).

**Also informed by:** the game's strength is the tight single-button speedrun loop; playtesting showed the top request is "more content"; the author can build levels fast (17 levels in ~2 weeks); a 2-year runway exists (Steam launch currently ~2 years out, can compress to ~12 months).

### Decisions

| # | Topic | Decision | Rationale |
|---|---|---|---|
| 1 | Product identity | **Editor-first.** The level editor + Steam Workshop is the main value proposition. The handcrafted campaign teaches mechanics and demonstrates what good levels look like. | Competing on handcrafted levels alone is a losing battle against legendary games. Editor + Workshop + ML is an uncontested niche. |
| 2 | ML/AI mode | **Visible but not central.** Mentioned on the store page. Starter code and tutorials on an external blog/source. Not a separate AI-development product. | AI hype is a differentiator that gets coverage from ML YouTubers and workshop audiences. Building a full AI product is out of scope. |
| 3 | Launch strategy | **Early Access.** EA in Dec 2026 at $9.99. 1.0 in Aug 2027 at $12.99. | Editor-first games benefit from a community content snowball. Two visibility bumps (EA + 1.0). Revenue starts in ~4 months instead of ~12. Editor gets battle-tested by real users before 1.0. |
| 4 | EA content | **25–30 campaign levels + editor + Workshop + basic arcade + basic ML mode.** | Enough to teach all mechanics and show what's possible. The editor is the infinite content engine. |
| 5 | 1.0 content | **35–40 campaign levels + world-based arcade + boss levels + daily/weekly challenges + full polish + ML tutorials.** | Substantial content bump justifies leaving EA and the price increase. |
| 6 | Price | **$9.99 EA, $12.99 1.0.** 20% launch discount at 1.0. Frequent 30–40% sales post-launch. | EA discount from full price is standard convention. Higher base anchors value; sales bring it into impulse-buy range ($7.79–$9.09). Can lower permanently later; can't raise. |
| 7 | Arcade mode | **World-based.** 5 worlds, each with 6–8 levels + 1 boss level. Pick a world → play all levels with 3 lives → score submitted to world leaderboard. "Gauntlet" mode unlocks after all worlds cleared. | Clear progression units. A world run is 5–10 minutes — perfect for "one more run." |
| 8 | Daily/weekly challenges | **Procedurally generated from seeds.** Daily: one seed, leaderboard resets at midnight. Weekly: harder curated seed, runs Monday–Sunday. | Retention engine. "Wordle effect" — players come back daily. |
| 9 | Leaderboard strategy | **Steam for campaign levels, SilentWolf for daily/weekly challenges and arcade.** | Steam leaderboards are permanent and prestigious. SilentWolf handles time-windowed queries without needing to clear leaderboards. |
| 10 | Workshop | **Launch feature (EA).** In-game level editor using symbol-based format. Steam Workshop for sharing/downloading. | This is the product. Ships day 1 of EA. |
| 11 | Roguelike mode | **Shelved.** | Daily/weekly challenges give the same "fresh run every day" retention without building a second game. |
| 12 | Multiplayer | **Shelved.** | Scope black hole. Playtesters didn't ask for it. |

---

## 2026-08-05 — Forgiving air jump ("fake coyote time")

**Context:** Recent state-machine bugfixing (walking off a ledge or leaving a wall no longer allowed a jump mid-air) removed a forgiveness behavior players relied on.

- **Decided to reintroduce it as "one free jump per airtime."** A new `has_jumped` flag on `Player` is set by `JumpState.enter()` and cleared by `Player._physics_process` when grounded. `FallState` grants a free `Jump` while `has_jumped` is false, consuming nothing.
- **Powerups are the only source of *extra* air jumps.** The free jump branch runs before the powerup branch, so a free jump never burns a powerup. Fall → free jump → powerup jump works as expected.
- **No free double jump:** every real jump (ground, wall, powerup, dash, bounce) sets `has_jumped`, so after using a jump in an arc only powerups can jump again.
- **Landing-frame tap:** pressing jump right as you land fires the free jump instead of a buffered ground jump. Both produce the same jump, so no gameplay difference.
