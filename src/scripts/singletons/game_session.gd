extends Node

## GameSession
## Ephemeral session state: current level, current seed, run flags.

var level_name: String = ""
var speed_modifier: float = 1.0
var run_seed: int = 0


func start_run(new_level_name: String, new_speed_modifier: float = 1.0) -> void:
	level_name = new_level_name
	speed_modifier = new_speed_modifier
	run_seed = randi()


func clear() -> void:
	level_name = ""
	speed_modifier = 1.0
	run_seed = 0