extends Polygon2D

## Background polygon that matches the level outline. Updated when the level
## emits level_outline_updated.

func _on_level_level_outline_updated(level_outline: Array) -> void:
	polygon = PackedVector2Array(level_outline)