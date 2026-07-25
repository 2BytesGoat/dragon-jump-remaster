class_name MedalConfig
extends Resource

## Medal names and colors used across the UI.
## Also maps medal tiers to cosmetic unlocks.

@export var medal_names: Array[String] = ["BRONZE", "SILVER", "GOLD"]
@export var medal_colors: Array[Color] = [
	Color(0.804, 0.502, 0.196, 1.0),
	Color(0.753, 0.753, 0.753, 1.0),
	Color(0.996, 0.843, 0.0, 1.0)
]

## Cosmetic IDs unlocked when reaching each medal tier.
@export var cosmetics_by_milestone: Array[String] = [
	"",
	"silver_crown",
	"golden_dragon",
]


## Returns the cosmetic id unlocked at the given milestone index, if any.
func get_cosmetic_for_milestone(milestone: int) -> String:
	if milestone < 0 or milestone >= cosmetics_by_milestone.size():
		return ""
	return cosmetics_by_milestone[milestone]
