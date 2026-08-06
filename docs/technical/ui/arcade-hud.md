# Arcade HUD and Run Timer

## Live HUD (`arcade_rank_hud.tscn`)

`ArcadeRankHud` is the on-screen HUD during gameplay (main.tscn:58), a `CanvasLayer` containing the lives counter, the run timer, the medal/rank bar, bonus popups, score, and death/clear SFX. It is **not** the `ArcadeHud` described below — that was a design draft and was never built.

- Script: `src/ui/components/arcade_rank_hud.gd` (score roll, rank bands, medals, popups)
- Scene: `src/ui/components/arcade_rank_hud.tscn`
- Node path in `main.tscn`: `SubViewportContainer/SubViewport/CanvasLayer/ArcadeRankHud`

### `ArcadeHud` design draft
There was previously a design draft proposing a new `ArcadeHud` (bigger timer, lives counter, fixed power-up slots). **It was never implemented** — the draft file was rewritten into this doc, and the live HUD is `ArcadeRankHud` above. Do not mistake any past references to "`ArcadeHud` draft" for current code; it is backlog work (see `docs/project/active-backlog.md`).

## Run Timer (`single_time_container.gd`)

The run timer is a `MarginContainer` (`TimeContainer`) nested inside `ArcadeRankHud`, with script `single_time_container.gd` attached (arcade_rank_hud.tscn:28-39). `main.gd` references it via `time_container` (main.tscn:57). `docs/technical/ui/index.md` lists `src/ui/components/single_time_container.gd`; there is also a stale, unused `src/ui/components/time_container.tscn` draft.

### What it does

- **Display timer** (`total_time`): counts up while the race is active (first jump → finish), shown in `TimeLabel`. This is the clear time shown to the player and used for ranks/best times.
- **Session accumulator** (`session_elapsed`): accumulates the same active-run time but **survives `reset()`** (deaths and restarts). It is flushed to `SignalBus.play_time_elapsed`, which `SaveManager` adds to the total/daily/weekly "time played" retention counters. So time on failed runs and restarts is recorded even though it never appears on the timer.
- **Race gating**: time accumulates only when `race_started && !race_paused`. Paused time and pre-first-jump reading time are excluded. The `game_paused` signal (main.tscn:187) drives the pause gate.

### Signals consumed (from `Player`)

| Signal | Handler effect |
|--------|----------------|
| `run_started` | Starts the race (and the accumulator) |
| `run_restarted` | Flushes accumulated time to the bus, then resets the display timer |
| `run_finished` | Stops the race and flushes remaining time |

### Flush points for `SignalBus.play_time_elapsed`

- Every ~10 s of active play (see `FLUSH_INTERVAL_SEC`)
- On `run_restarted` (covers death respawn + manual restart)
- On `run_finished`
- On `_exit_tree` (covers level exit / game quit, bounding data loss to a few seconds)

### Flow

```
Player signals ──> single_time_container.gd ──> SignalBus.play_time_elapsed ──> SaveManager._on_time_elapsed ──> GameData total/daily/weekly_time_played_seconds
```

## See Also

- [[technical/save-system/index]] — retention counters and `_on_time_elapsed`
- [[technical/signal-bus]] — `play_time_elapsed` signal
- [[technical/player-system]] — player lifecycle signals
- [[technical/main-system]] — timer wiring in `main.gd` / `main.tscn`
