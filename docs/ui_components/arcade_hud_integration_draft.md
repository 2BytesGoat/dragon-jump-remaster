# Arcade HUD integration draft

## What changed and why

The current HUD (`TimeContainer`) is a single small timer at the top center. The power-up cards are rendered by `CardContainerContainer`, which spreads panels across the whole screen using a `VBoxContainer`. That layout works for a mouse-driven RTS but is hard to read quickly and is not controller friendly.

This draft introduces `ArcadeHud`:
- a bold top bar with **level badge**, **big centered timer**, and **lives counter**;
- a bottom power-up bar with three fixed 40×40 slots;
- a small script that mirrors the existing `TimeContainer` + `CardContainerContainer` API so integration is minimal.

## Files added

- `src/ui/components/arcade_hud.tscn` — the new HUD scene.
- `src/ui/components/arcade_hud.gd` — HUD logic.

## Suggested wiring in `main.tscn`

1. Add an `ArcadeHud` instance under `SubViewportContainer/SubViewport/CanvasLayer`.
2. Keep `PauseScreen` and `EndScreen` as they are; only hide or remove `TimeContainer` and `CardContainerContainer` when you are ready to switch.

Example node path after integration:

```
SubViewportContainer/SubViewport/CanvasLayer
├── ArcadeHud        <-- new
├── PauseScreen
├── EndScreen
```

If you want to try it side-by-side first, set `TimeContainer.visible = false` and `CardContainerContainer.visible = false` instead of deleting them.

## Suggested wiring in `main.gd`

Add an export for the new HUD and remove / deprecate the old ones:

```gdscript
@export var arcade_hud: MarginContainer
# @export var time_container: MarginContainer   # can be removed later
# @export var card_container: VBoxContainer     # can be removed later
```

In `_ready`:

```gdscript
arcade_hud.set_level_name(level_name)
arcade_hud.set_lives(3)   # or however many lives you use
```

In `initialize_players`:

```gdscript
arcade_hud.track_player(player)
# time_container.track_player(player)   # remove
# card_container.map_player_signals(player_nodes)  # remove
```

To drive the timer, add a `_process` to `main.gd`:

```gdscript
func _process(delta: float) -> void:
	if not race_finished:
		arcade_hud.update_time(delta)
```

`ArcadeHud.reset()` is already wired to player restart signals, so `reset_ui` can be simplified to:

```gdscript
func reset_ui():
	set_game_paused(false)
	arcade_hud.reset()
	race_finished = false
	end_screen.visible = false
```

## Controller / arcade considerations

- All text uses large font sizes (20–24 px) for cabinet screens.
- The power-up slots are fixed left-to-right slots, making it easy to show a selection highlight or button prompt later.
- The top bar spans the full width so it is readable at a glance.
- If you add a selected-slot indicator, add a `TextureRect` or `Panel` highlight under `PowerupContainer` and animate its `position` based on the active slot index.

## Next steps / optional polish

1. Apply your existing `level_select_theme.tres` to `ArcadeHud` so fonts and colors match the rest of the game.
2. Style the `Panel` nodes with `StyleBoxFlat` fills (dark background + bright border) for an arcade bezel look.
3. Add a `HIGH SCORE` / `BEST` label next to the timer if you want classic arcade flavor.
4. If you support two players locally, duplicate the bottom bar or stack two rows.
5. Replace the placeholder `Panel` slots with your existing `card_scene.tscn` sizing so the power-up icons feel consistent.
