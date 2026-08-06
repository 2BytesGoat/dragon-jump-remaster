class_name BonusPopupConfig
extends Resource

## Timing/visual tuning for the reusable BonusPopup component.
## Shared single source of truth — every spawned popup reads from here.

@export var drift: float = 24.0
@export var pop_in_time: float = 0.15
@export var fade_out_time: float = 0.3
@export var lifetime: float = 1.1

## World-space offset applied to the spawn position before converting to screen.
## Keeps the popup pinned above the player regardless of camera position.
@export var position_offset: Vector2 = Vector2(0, 16)
