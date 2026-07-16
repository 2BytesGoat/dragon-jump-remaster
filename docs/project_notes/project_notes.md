---
title: Project Notes and Decision Log
tags: [godot, game-engine, project-management, decision-log, roadmap]
related:
  - "[[architecture]]"
  - "[[main_system]]"
  - "[[player_system]]"
  - "[[level_system]]"
  - "[[rl_integration_system]]"
search_terms: [project-notes, decision-log, roadmap, scope, next-steps, known-issues, audit]
---

# Project Notes and Decision Log

This document captures high-level project observations, open questions, known issues, and decisions as the project evolves. It is meant to be a living reference for both humans and the AI assistant.

Last updated: 2026-07-17

## Current project snapshot

Dragon Jump Remaster is a **2D single-button speedrun platformer** built in Godot 4.6.

### What is implemented and working today

- 16 hand-authored campaign levels defined by symbol-based level codes.
- Auto-run player with one input: jump/reset.
- Power-ups: DoubleJump, Dash, Stomp, Grapple (consumed from a stack of up to 3).
- Save system with per-level attempts, best times, progress milestones, and medal thresholds.
- Leaderboard integration via the SilentWolf addon.
- Symbol-driven level parsing and tilemap generation.
- A full reinforcement-learning training mode using `godot-rl-agents` with a custom synchronizer and AI controller.
- Basic UI: main menu, level select, pause screen, end screen, leaderboard display.

### What the README promises but is not yet shipped

The top-level [README.md](/README.md) describes a much broader product:

- Demo: co-op/bot race, 20 practice maps, load maps from friends.
- Full game: online multiplayer, map editor, more maps, custom game modes.
- Game modes: tag-mode (crown race), chicken-horse (map editing between rounds).

In reality, the playable game is a linear single-player speedrun campaign. The crown tile, progress bar, and multiplayer level dictionary exist in code but are not part of the main player-facing loop.

## Core tension: what is this game?

There are three plausible identities on the table. This is the main decision that needs to be made before adding more features.

### Option A: Ship the speedrun campaign

Focus on polishing the 16 levels, the save/leaderboard loop, and the feel of the one-button runner. Treat multiplayer, editor, and RL as future milestones.

Pros:
- Smallest scope.
- Uses everything that already works.
- Clear player value proposition.

Cons:
- Does not match the README’s stated ambition.
- May feel too small if the original vision was bigger.

### Option B: Pivot to the RL training environment

Lean into the `godot-rl-agents` integration, the custom synchronizer, and the AI controller. Make the project a research/sandbox tool for training agents to speedrun platformer levels.

Pros:
- The training infrastructure is already substantial.
- Differentiates the project from a simple platformer.

Cons:
- The human-facing game becomes secondary.
- Requires documenting and stabilizing the Python/Godot training pipeline.

### Option C: Speedrun campaign + ghost race mode (recommended)

Keep the campaign as the core, but add a ghost race mode where the player races against their own best time or a bot ghost. This is the smallest step toward the README’s “race a friend/bot” promise and uses the existing `Ghost` scene.

Pros:
- Builds on working systems.
- Gives the game a clear hook beyond just finishing levels.
- Uses assets that already exist (`ghost.gd`, `ghost.tscn`, save data with best times).

Cons:
- Still requires UI work to expose the mode.
- Ghost replay needs deterministic recording/playback.

## Known issues and code-quality notes

These were found during the 2026-07-17 audit. They should be fixed regardless of which option is chosen.

### Bugs

- [ ] [src/ui/menus/main_menu.gd](/src/ui/menus/main_menu.gd#L4) uses `"src/ui/menus/level_select.tscn"` without the `res://` prefix. Scene navigation will fail.
- [ ] [src/ui/end_screen.gd](/src/ui/end_screen.gd) expects `stats["restarts"]` and `stats["crowns_dropped"]`, but [src/main.gd](/main.gd) comments them out, so the end screen shows wrong/empty values.
- [ ] [src/scripts/singletons/save_manager.gd](/src/scripts/singletons/save_manager.gd) `unlock_next_level` has confusing off-by-one guard logic and does not handle the final level gracefully.

### Code quality / typos

- [ ] [src/scripts/singletons/constants.gd](/src/scripts/singletons/constants.gd) has `MEDAL_NAMES = ["BRONZE", "SIVLER", "GOLD"]` — “SIVLER” should be “SILVER”.
- [ ] [src/scenes/player/player.gd](/src/scenes/player/player.gd) uses `last_agent_intput` (typo) throughout `set_jump`.
- [ ] [src/scenes/player/gapling_hook.gd](/src/scenes/player/gapling_hook.gd) and the `GaplingHook` node name are misspelled (“grappling”).
- [ ] [src/scenes/training/main_multiplayer.gd](/src/scenes/training/main_multiplayer.gd) has a hardcoded `DEFAULT_LEVEL_NAME = "1-14"` and a TODO to loop through all levels.

### Documentation drift

- [ ] `docs/player_system/player_system.md` mentions crown/tag mechanics but does not explain them in the context of the current game.
- [ ] `docs/main_system/main_system.md` references a `time_container` property that does not exist in [main.gd](/main.gd).
- [ ] `docs/ui_components/ui_components.md` documents `progress_bar.gd` crown logic that is only relevant for an unimplemented tag/crown mode.
- [ ] `docs/rl_integration_system/rl_integration_system.md` documents the addon’s `sync.gd`, but the project also has a custom `src/scenes/training/synchronizer.gd` that is not documented.
- [ ] `docs/documentation_tracking.md` has incorrect paths for level system docs (e.g. links to `/docs/level_system.md` instead of `/docs/level_system/level_system.md`).
- [ ] `src/scenes/training/multiplayer_world.gd` is not tracked or documented.

## Architectural antipatterns and structural concerns

These are not bugs, but they contribute to the feeling that the codebase is messy or hard to reason about. They should be addressed after the competition deadline.

### 1. Multiple product identities in one codebase

The repo currently contains at least three products:
- A single-player speedrun campaign (the playable game).
- A FunRun-style crown/tag race mode (crown tile, progress bar, `MULTIPLAYER_LEVELS`).
- A full RL training environment (`godot-rl-agents`, custom synchronizer, `PlayerAITrainingController`).

They share code but serve different masters. This makes every change feel risky because it is unclear which product is being broken or extended.

**Recommended fix:** Decide the one product identity for the first release and move shelved experiments into a separate folder, branch, or build target. The current agreed identity is the arcade-style speedrun campaign with hidden AI training mode.

### 2. Unused or half-implemented features left in the main path

- `MULTIPLAYER_LEVELS` in `constants.gd` is large but unused in the normal game flow.
- Crown and progress bar logic is wired but not part of the player-facing loop.
- `end_screen.gd` expects stats that `main.gd` does not provide.

**Recommended fix:** Either finish and expose these features, or remove/hide them so they stop creating dead-code anxiety.

### 3. Inconsistent naming and typos

- `GaplingHook` / `gapling_hook.gd` should be `GrapplingHook`.
- `last_agent_intput` should be `last_agent_input`.
- `SceneManger` should be `SceneManager`.
- `emplased_time` in `level.gd` should be `elapsed_time`.

**Recommended fix:** A focused naming-cleanup commit. This is low risk and makes the project feel much cleaner.

### 4. Magic numbers and hardcoded defaults

- `main_multiplayer.gd`: `DEFAULT_LEVEL_NAME = "1-14"`, `DEFAULT_NB_AGENTS = 1`.
- `main.gd`: `level_name = "1-10"` as fallback.
- Medal thresholds computed inline as `base_time * 2.5`, `* 1.65`, `* 1.2`.

**Recommended fix:** Move these into `Constants` or exported properties so balancing does not require code edits.

### 5. AI controller is tightly coupled to the player

`PlayerAITrainingController` reaches directly into `player.level_reference`, `player.state_machine`, `player.global_position`, etc. This is acceptable for a research tool but means the AI mode is embedded rather than layered.

**Recommended fix:** Keep as-is for the competition, but consider a cleaner observation interface later so the AI does not need to know internal player state.

### 6. Documentation drift

The docs are thorough but already describe things that no longer exist or systems that are not active. This makes documentation feel like a burden.

**Recommended fix:** After scope is decided, prune or mark shelved sections clearly. Docs should describe what runs, not every idea that was tried.

## Proposed Version 1.0 scope

This is a draft scope meant to combat decision fatigue. The goal is a small, shippable game that the author is not embarrassed to release. Items should be approved, cut, or questioned one by one.

### Must ship (core loop)

- [ ] 16 existing campaign levels, playable from start to finish.
- [ ] Single-button speedrun gameplay (auto-run, jump/reset).
- [ ] Save system: attempts, best times, medals, level unlocks.
- [ ] Main menu, level select, pause screen, end screen.
- [ ] Basic sound and effects already in the project.

### Should ship (polish)

- [ ] Fix known small bugs and typos from the audit.
- [ ] Make sure the end screen shows correct stats.
- [ ] Ensure main menu navigation works.
- [ ] Add 1 new competition level (`1-17`) for the ML workshop.
- [ ] RL-side distinct-cells-touched tracking for the competition.

### Could ship (nice to have)

- [ ] Ghost race mode (race your own best time).
- [ ] Leaderboard integration fully working.
- [ ] A few more levels beyond 1-17.

### Cool but shelved for V1.0

- [ ] QR-code level sharing: generate a QR from a level code, let people edit on their phone, upload back into the game. Excellent arcade integration idea, but requires a web editor + QR generation + import flow. Save for V1.1 or an arcade-specific build.
- [ ] Co-op / bot race.
- [ ] FunRun crown/tag mode.
- [ ] Full map editor.
- [ ] Chicken-horse mode.
- [ ] Online multiplayer beyond SilentWolf leaderboard.
- [ ] Arcade limited-lives mode.

### Open decisions

- [ ] Steam release first, arcade machine first, or both at the same time?
- [ ] Is the AI training mode a hidden menu in the same build, or a separate build/launch flag?
- [ ] What is the exact release deadline for V1.0?

## Suggested next steps

1. Approve or edit the proposed V1.0 scope above.
2. Fix the small bugs and typos listed above.
3. Add the competition level and RL-side distinct-cells tracking for next week.
4. Update the top-level README and release plan to match the agreed scope.
5. Refresh the LightRAG inputs after docs are updated so the AI assistant has accurate context.

## Open questions

- Should the RL training mode remain a first-class feature or become a separate build target?
- Should the crown/progress bar/tag-mode code be removed, hidden, or fully implemented?
- What is the target platform and release channel (itch.io, Steam, internal research demo)?
- Is there a desired level count for a first public build?

## Project history and context

This section captures the human story behind the project so future decisions can account for it.

- The project started ~2 years ago as a game jam entry and has been rewritten roughly 5 times.
- It is the author’s largest project to date, which contributes to the feeling that it is never “done enough.”
- At one point a player liked the demo so much they offered to buy it. The author declined because the dream was to release it for ~$5 with a hidden AI training mode that teaches people how to build basic AI.
- No new levels have been added in ~1.5 years.
- There was an earlier attempt to copy the layout of FunRun: one big level (~1 minute), grab a crown, race back to the end. If you got reset, another player could steal the crown. This explains the crown tile, progress bar, and tag-mode code that currently sits unused.
- The project has been used in ML workshops where participants train AIs for it.

## Psychological / creative context

This is the author’s first large game project. The emotional weight attached to it is high because:
- It represents a lot of accumulated time and effort.
- Some of that time was driven by burnout and workplace resentment, making the project feel like an escape route.
- There is a dream that shipping it successfully could lead to working independently.
- The fear is not that the game is bad — it is that releasing it “wrong” would waste all of that investment.

The result is pressure to make the project perfect, which leads to scope expansion, rewrites, and avoidance. The healthier framing is:

> **The goal is not to make a perfect game. The goal is to finish a small, coherent game and learn from releasing it.**

Practical consequences for how this project should be managed:
- Keep tasks tiny and completable in one session.
- Celebrate shipped milestones, not just started ones.
- Avoid adding new product visions mid-task.
- Treat the first public build as a learning artifact, not a life-changing event.
- The AI assistant should keep reminding the user of the agreed small scope and encourage completion over expansion.

## Current external deadline

- **ML workshop final competition: next week.**
- Requirements for the competition:
  - Create 1 new custom level.
  - Add logic to count how many distinct tiles the player touched during a run.
  - The mini-competition rule: win by crossing almost the entire map before finishing.

## Long-term goals

1. Release on Steam for a low price (~$5) and have people not hate it.
2. Earn some money from it.
3. Use it as the icebreaker game on a custom arcade machine for the author’s gamedev community.
4. Keep the AI training mode as a hidden/tinkerer feature, especially for the Steam audience.

## Refined product identity

Based on the above, the most coherent product identity is:

> **Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.**

This means:
- The core player experience is the speedrun campaign.
- The RL/training infrastructure is a value-add, not the main product.
- The FunRun/crown/tag mode is a shelved experiment unless explicitly revived.
- The arcade build can be the same campaign, possibly with a simpler menu and no online leaderboard.

## Post-competition / arcade direction

- Arcade build idea: switch to a limited-lives system (3 lives by default).
- Players can find hidden extra lives behind secret walls (`M` tiles).
- This reinforces the arcade icebreaker goal and gives the campaign a different tension than the Steam speedrun mode.
- This should be implemented after the ML workshop competition, not before.

## Decisions made

- 2026-07-17: Created this decision log to capture the current state and prevent findings from being lost.
- 2026-07-17: Refined product identity to **arcade-style speedrun platformer with hidden AI training mode** based on project history and long-term goals.
- 2026-07-17: Added competition level `1-17` and distinct-tiles-touched tracking for the upcoming ML workshop final competition.
