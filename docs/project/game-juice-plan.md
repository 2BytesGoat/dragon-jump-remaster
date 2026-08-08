---
title: Game Juice Plan
tags: [godot, game-engine, juice, polish, ui, feedback, dopamine, arcade]
related:
  - "[[project/active-backlog]]"
  - "[[technical/ui/index]]"
  - "[[technical/effects]]"
search_terms: [juice, dopamine, ui-animation, score-popup, screen-flash, sfx, count-up, medal-bar, streak, retention]
---

# Game Juice Plan

Goal: make the reward loop say *"look at me, play me for some more time"* — Vampire Survivors / slot-machine style dopamine. The game already has strong **gameplay** juice (screen shake, hit stop, transition wipe, card draw/dissolve, smoke effects). The gaps are all in the **reward loop**: score feedback, clear celebrations, and sound.

## Checklist

Legend: `[x]` shipped · `[ ]` pending · `[~]` partial / known issue.

### Tier 1 — core reward juice

| Status | Item | Notes |
|---|---|---|
| [x] | Score count-up roll | `hud.gd` `_roll_score` (0.6s ease-out). **Known issue:** never plays on clear — reset kills the tween (see P0-1). |
| [x] | Floating "+N" popup | Drifts up from rank card. **Known issue:** overlaps the rank card; merge into it (P3-1). |
| [x] | Screen flash on clear | Rank-colored full-screen tint. **Known issue:** same reset-kill problem (P0-1). |
| [x] | Medal drain bar + heartbeat pulse | Drains across the band; pulses below 50% fill, faster as it empties. **Known issue:** no band threshold markers on the bar (P1-2). |
| [x] | Band label pop | Colored GOLD/SILVER/BRONZE/--- under the bar. **Known issue:** font size 5, floats disconnected from the bar (P1). |
| [x] | Streak multiplier readout | Pops on clear, red death-reset to x1.00. **Known issue:** format `x%.2f` differs from game-over `x%.0f` (P2-2). |
| [~] | SFX for reward moments | Clear chime / gold jackpot / death thud wired up but **muted** — placeholder assets (`SoundBonus.wav`, `SoundSlide.wav`) in repo; sourcing decision pending (Open questions). |

### Tier 2 — celebration moments

| Status | Item | Notes |
|---|---|---|
| [~] | Streak milestone celebrations | Best-streak stat shipped; x3/x5/x10 banners + confetti not implemented. |
| [ ] | Gold confetti burst | Not implemented. |
| [x] | Game-over score roll | 0.8s ease-out count-up. **Known issue:** runs behind the overlay with no delay, and NEW HIGH SCORE blink snaps back to full alpha (P3-2). |
| [x] | Leaderboard stagger | Entries pop in 50ms apart, TRANS_BACK. |
| [x] | NEW HIGH SCORE pop | Scale pop + fade. **Known issue:** fade-out callback snaps back to full alpha — reads as a glitch (P3-2). |

### Tier 3 — retention polish

| Status | Item | Notes |
|---|---|---|
| [x] | Menu button hover/click scale-pop | 1.08 hover / 0.92 press / TRANS_BACK. |
| [x] | Best-streak stat on game over | `ArcadeDirector.best_streak`. |
| [x] | Timer tension tick | Bar flashes brighter + pulses below 50% of band. |
| [ ] | Rank card honesty | Card shows streak multiplier but implies it equals the time rank. Show both factors (P2-1). |

## Work items (from 2026-08-04 UX review)

### P0 — make the juice actually play

- [ ] **P0-1 Celebrations are killed the same frame they start.** `main.gd:_on_arcade_level_finished` calls `on_level_finished()` (emits `level_rank_awarded` → starts rank card / popup / flash tweens) then synchronously `update_level()` + `reset_ui()` → `arcade_rank_hud.reset()` kills all celebration tweens and hides them. Score count-up never rolls either (reset snapshots the already-banked score). **Fix:** pause players, `await` 1.3s so the celebration plays over the finished level, then advance; same pause before the game-over screen on the final clear.
- [ ] **P0-2 HUD reset conflates pace state with celebrations.** Split `arcade_rank_hud.reset()` so level transitions reset timer/bar/band/score without killing mid-flight celebration tweens (needed after P0-1 to avoid double-clear edge cases).
- [ ] **P0-3 Score/multiplier shows in practice mode** where the score system is inactive. Hide the score readout outside arcade mode (medal pace bar stays visible in practice — it's useful pacing info; the score is not).

### P1 — restructure the pace cluster (timer + bar + medal text)

Current top-center stack is three disconnected fragments with inverted hierarchy: timer is font 14 (biggest element on screen), the medal bar is a 5px sliver, and the band label is font 5 floating 17px below the bar with no visual connection.

- [ ] **P1-1 One centered stack** (~180px wide, 2px separation): dimmed timer (font ~9) → medal bar (~10px) → colored band label (font ~8) integrated under the bar.
- [ ] **P1-2 Band threshold ticks.** Draw GOLD/SILVER/BRONZE threshold markers on the bar so the fill visibly drains *through* them — the player can see how close they are to losing their band. This is the single most important missing piece of arcade information.
- [ ] **P1-3 Enlarge the top-right score** (font ~10) and restyle the multiplier as a small colored chip; keep the count-up and death-reset animations.

### P2 — honest reward feedback

- [ ] **P2-1 Rank card shows both factors**: `GOLD ×1.50 · ×2 = +4000` (time multiplier × streak multiplier = total bonus). Today the card shows the streak multiplier colored by the time rank — the player cannot decompose their reward.
- [ ] **P2-2 Unify streak formatting**: `x%.2f` in the HUD and on the game-over "BEST STREAK" line.

### P3 — small polish

- [ ] **P3-1 Merge the floating "+N" into the rank card** (they overlap at center screen); drop the separate drifting label or make it a short rise from the card.
- [ ] **P3-2 Fix NEW HIGH SCORE blink**: the fade-out tween's callback snaps the label back to full alpha. Settle at a steady state instead.

## Open questions

- **SFX sourcing:** only 2 SFX exist (`SoundBonus.wav`, `SoundSlide.wav`). Real clear/gold/death sounds need a source decision (freesound / opengameart, see `assets/sfx/sources.txt`). SFX calls remain commented out in `hud.gd` until then (decision 2026-08-04: keep muted).
- **Flash intensity:** full-screen tint vs. edge vignette — tune after playtest.
- **Clear pause length:** P0-1 uses a fixed 1.3s. Tune after playtest; the alternative is awaiting the rank-card tween (~1.6s).
