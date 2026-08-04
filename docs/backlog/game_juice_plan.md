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
5. **SFX for reward moments** — clear chime, gold "jackpot" sound, death thud. Placeholder assets from the existing pool (`SoundBonus.wav`, `SoundSlide.wav`) until real sounds are sourced.

## Tier 2 — celebration moments (not yet implemented)

- Streak milestone celebrations at x3 / x5 / x10 (banner + bigger flash + particle burst).
- Gold confetti burst on GOLD rank (GPUParticles2D).
- Game-over screen juice: score counts up, leaderboard entries pop in staggered, "NEW HIGH SCORE" banner flash.

## Tier 3 — retention polish (not yet implemented)

- Menu button hover/click scale-pop (`menu_button.gd` currently does nothing on hover).
- Best-streak stat on game over ("BEST STREAK x7") — a chase target per run.
- Timer tension tick in the last ~10% of a medal band.

## Open questions

- **SFX sourcing:** only 2 SFX exist (`SoundBonus.wav`, `SoundSlide.wav`). Real clear/gold/death sounds need a source decision (freesound / opengameart, see `assets/sfx/sources.txt`).
- **Flash intensity:** full-screen tint vs. edge vignette — tune after playtest.
