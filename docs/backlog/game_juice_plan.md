---
title: Game Juice Plan
tags: [godot, game-engine, juice, polish, ui, feedback, dopamine, arcade]
related:
  - "[[tracking/backlog]]"
  - "[[systems/ui_components/ui_components]]"
  - "[[systems/effects/effects]]"
search_terms: [juice, dopamine, ui-animation, score-popup, screen-flash, sfx, count-up, medal-bar, streak, retention]
---

# Game Juice Plan

Goal: make the reward loop say *"look at me, play me for some more time"* — Vampire Survivors / slot-machine style dopamine. The game already has strong **gameplay** juice (screen shake, hit stop, transition wipe, card draw/dissolve, smoke effects). The gaps are all in the **reward loop**: score feedback, clear celebrations, and sound.

## Current state (2026-08-04)

| System | Status |
|--------|--------|
| Screen shake / hit stop / wipe | Shipped (death + powerup only) |
| Card draw / dissolve | Shipped |
| Rank card pop, multiplier pop, band label pop | Shipped (arcade HUD) |
| Medal drain bar | Shipped (instant fill, no pulse) |
| Score label | Instant text swap — **no count-up** |
| SFX on clear / rank / death / game over | **None** (only powerup pickup + smoke pops) |
| End screen / game-over screen | Static (one hint blink) |
| Floating "+N" popups | **None** |
| Screen flash on clear | **None** |
| Menu button hover/click | **None** |

## Tier 1 — core reward juice (implemented 2026-08-04)

1. **Score count-up roll** — digits animate old → new over ~0.6s with ease-out (slot-machine reel feel). `arcade_rank_hud.gd`.
2. **Floating "+N" popup** — on level clear, a "+4000" drifts up from the rank card and fades (Vampire Survivors style).
3. **Screen flash on clear** — quick full-screen tint flash, colored by rank (gold for GOLD/GOLD+, silver, bronze).
4. **Medal bar pulse** — tweened fill + scale pulse when crossing into a new band (was instant).
5. **SFX for reward moments** — clear chime, gold "jackpot" sound, death thud. Placeholder assets from the existing pool (`SoundBonus.wav`, `SoundSlide.wav`) until real sounds are sourced. **Calls commented out — see Open questions.**

## Tier 2 — celebration moments (implemented 2026-08-04)

- **Streak milestone celebrations** at x3 / x5 / x10 — "STREAK xN!" banner pops above the rank card, gold flash, confetti burst.
- **Gold confetti burst** on GOLD/GOLD+ rank (GPUParticles2D, gold/silver/bronze/white palette).
- **Game-over screen juice:** score counts up (0.8s ease-out), "NEW HIGH SCORE!" pops and flashes, leaderboard entries pop in staggered (50ms apart, TRANS_BACK).

## Tier 3 — retention polish (implemented 2026-08-04)

- **Menu button hover/click scale-pop** — `menu_button.gd` now scales on focus/hover (1.08), press (0.92), release (1.08) with TRANS_BACK.
- **Best-streak stat on game over** — "BEST STREAK xN" shown on the game-over screen; tracked in `ArcadeDirector.best_streak` (max consecutive clears per run).
- **Timer tension tick** — the medal bar flashes brighter + pulses once when the fill drops below 10% of the current band (once per band).

## Open questions

- **SFX sourcing:** only 2 SFX exist (`SoundBonus.wav`, `SoundSlide.wav`). Real clear/gold/death sounds need a source decision (freesound / opengameart, see `assets/sfx/sources.txt`). SFX calls are commented out in `arcade_rank_hud.gd` until then.
- **Flash intensity:** full-screen tint vs. edge vignette — tune after playtest.
