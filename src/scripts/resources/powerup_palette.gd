class_name PowerupPalette
extends Resource

## Color mapping for each powerup type.

@export var colors: Dictionary = {
	"DoubleJump": Color(0.729, 0.212, 0.333, 1.0),
	"Stomp": Color(0.475, 0.839, 0.247, 1.0),
	"Dash": Color(0.204, 0.329, 0.529, 1.0),
	"Grapple": Color(0.176, 0.839, 0.988, 1.0)
}


func get_color(powerup_type: String) -> Color:
	return colors.get(powerup_type, Color.WHITE)
