extends Node

## GameSession
## Ephemeral session state: current level, current seed, run flags.
enum GameModes {
	ARCADE,
	PRACTICE
}

var level_name: String = ""
var speed_modifier: float = 1.0
var run_seed: int = 0
var game_mode: GameModes = GameModes.PRACTICE


func set_game_mode(mode: GameModes) -> void:
	game_mode = mode


func start_run(new_level_name: String, new_speed_modifier: float = 1.0) -> void:
	level_name = new_level_name
	speed_modifier = new_speed_modifier
	run_seed = randi()


func clear() -> void:
	level_name = ""
	speed_modifier = 1.0
	run_seed = 0
