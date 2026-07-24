# Decision Log — Dragon Jump Remaster

This document captures high-level decisions as the project evolves.

---

## 2026-07-17 — Product identity and early scope

- **Refined product identity** to:

  > Dragon Jump Remaster is an arcade-style single-button speedrun platformer. The Steam version adds a hidden AI training mode for players who want to tinker with reinforcement learning.

  Details: [[direction/product_identity]].

- **Decided V1.0 scope** is the polished 16-level speedrun campaign, with AI training as a hidden/tinkerer value-add. Multiplayer, crown/tag, editor, and chicken-horse are shelved.

- **Identified the upcoming ML workshop competition** as the immediate external deadline. Sprint plan: [[tracking/sprints/sprint_2026_07_25]].

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
| `SceneManger` / `scene_manger.gd` | `SceneManager` / `scene_manager.gd` | Done |
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
