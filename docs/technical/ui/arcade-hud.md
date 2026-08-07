# Arcade HUD and Run Timer

## Fonts

The live HUD (`ArcadeRankHud`) renders in `PressStart2P-Regular.ttf` via `src/ui/themes/gameplay_theme.tres`, applied to the HUD's root node in `arcade_rank_hud.tscn`. Menus and other in-game overlays (pause, end, game-over, powerup cards) keep `Awesome 9` (global theme, `default_theme.tres`). See [[project/decisions]] (two-font UI system) for the rationale.

## Live HUD (`arcade_rank_hud.tscn`)

`ArcadeRankHud` is the on-screen HUD during gameplay (main.tscn:58), a `MarginContainer` inside the gameplay `CanvasLayer`, containing the lives counter, the run timer, the medal/rank bar, score, and death/clear SFX. Bonus popups are spawned as children of that same `CanvasLayer` (which is in the `"GameplayHud"` group), not of the HUD container. It is **not** the `ArcadeHud` described below — that was a design draft and was never built. The medal bar and its medal icon (same sprite as the level-select buttons, `assets/sprites/ui/medals.png`) hide once the run time passes the bronze threshold, replaced by a "NO BONUS" label; all three reappear on level reset. The medal icon, medal bar, and "NO BONUS" label share a single parent (`MedalRow`, the inner `HBoxContainer` marked `unique_name_in_owner`) and all scale/pulse animations are applied to that shared parent, so the trio always pops together.

- Script: `src/ui/hud/arcade_rank_hud.gd` (score roll, rank bands, medals, popups)
- Scene: `src/ui/hud/arcade_rank_hud.tscn`
- Node path in `main.tscn`: `SubViewportContainer/SubViewport/CanvasLayer/ArcadeRankHud`

### Bonus popups (`bonus_popup.tscn`)

The "+bonus" popup shown at level clear is a **reusable, one-shot component**, not a static HUD child:

- Component: `src/ui/hud/bonus_popup.gd` + `bonus_popup.tscn` (`class_name BonusPopup`)
- Tuning: `resources/bonus_popup_config.tres` (`drift`, `pop_in_time`, `fade_out_time`, `lifetime`, `position_offset`) — the single shared source of truth for every spawned popup.
- `BonusPopup.spawn(parent, text, color, world_position)` instantiates a popup, parents it under the gameplay HUD `CanvasLayer` (main.tscn's `CanvasLayer` node), animates it (pop in → drift up → fade out) **above the given world position** (mapped to screen via `get_canvas_transform()`), then frees itself. Concurrent bonuses stack because each spawn is independent. The HUD container itself must not be the parent — container layout would overwrite the popup's position.
- The gameplay `CanvasLayer` is in the `"GameplayHud"` group (main.tscn), so world-side callers (future secret-area bonuses) can spawn via `BonusPopup.find_hud()` without a hard reference.
- `ArcadeRankHud` spawns it on `level_rank_awarded`; `main.gd` sets `pending_popup_world_position` to the player's finish position just before `ArcadeDirector.on_level_finished()` (whose `level_rank_awarded` emit is synchronous), so the popup appears above the player at the exit.

### `ArcadeHud` design draft
There was previously a design draft proposing a new `ArcadeHud` (bigger timer, lives counter, fixed power-up slots). **It was never implemented** — the draft file was rewritten into this doc, and the live HUD is `ArcadeRankHud` above. Do not mistake any past references to "`ArcadeHud` draft" for current code; it is backlog work (see `docs/project/active-backlog.md`).

## Run Timer (`run_timer.gd` + `time_display.gd`)

The run clock is split into two parts:

- **`RunTimer`** (`src/scripts/components/run_timer.gd`, `class_name RunTimer`) — a plain `Node` at the **main scene root** (`main.tscn` → `Main/RunTimer`, exported to `main.gd` as `run_timer`). It owns all timer state and logic. **This is the single source of truth for run time.**
- **`TimeDisplay`** (`src/ui/components/time_display.gd`, `class_name TimeDisplay`) — the `TimeContainer` MarginContainer inside `ArcadeRankHud` (arcade_rank_hud.tscn). It is **display-only**: it renders whatever time it is told via `set_time()` and holds no clock state. `main.tscn` connects `RunTimer.time_changed` → `TimeDisplay.set_time`.

`main.gd` wires everything: it connects player lifecycle signals to the timer via `run_timer.track_player(player)` (initialize_players) and hands the timer to the HUD with `arcade_rank_hud.run_timer = run_timer`. `ArcadeRankHud` reads `run_timer.total_time` / `run_timer.race_started` for medal-pace and rank-band visuals.

### What the timer does

- **Display timer** (`total_time`): counts up while the race is active (first jump → finish). `time_changed` fires each accumulated frame so the HUD label stays in sync.
- **Session accumulator** (`session_elapsed`): accumulates the same active-run time but **survives `reset()`** (deaths and restarts). It is flushed to `SignalBus.play_time_elapsed`, which `SaveManager` adds to the total/daily/weekly "time played" retention counters. So time on failed runs and restarts is recorded even though it never appears on the timer.
- **Race gating**: time accumulates only when `race_started && !race_paused`. Paused time and pre-first-jump reading time are excluded. The `game_paused` signal (main.tscn) drives the pause gate via `_on_main_game_paused`.

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
- On `reset()` (covers run resets that don't pass through `run_restarted`)

### Flow

```
Player signals ──> RunTimer ──┬─> time_changed ──> TimeDisplay (HUD label)
                              └─> SignalBus.play_time_elapsed ──> SaveManager._on_time_elapsed ──> GameData total/daily/weekly_time_played_seconds
```

## See Also

- [[technical/save-system/index]] — retention counters and `_on_time_elapsed`
- [[technical/signal-bus]] — `play_time_elapsed` signal
- [[technical/player-system]] — player lifecycle signals
- [[technical/main-system]] — timer wiring in `main.gd` / `main.tscn`
