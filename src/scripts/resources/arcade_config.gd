class_name ArcadeConfig
extends Resource

## Configuration for the arcade game mode.

@export var starting_level_id: String = "1-1"
@export var starting_lives: int = 3
@export var max_lives: int = 3
@export var level_clear_score: int = 1000

## Medal-band time multipliers. Continuous piecewise-linear between bands:
## t >= bronze -> bronze_multiplier, t -> 0s -> max_multiplier.
@export var bronze_multiplier: float = 1.0
@export var silver_multiplier: float = 1.5
@export var gold_multiplier: float = 2.0
@export var max_multiplier: float = 3.0
