extends Node

## ArcadeDirector
## Central controller for arcade mode setup, life tracking, and run progression.

const ArcadeConfig := preload("res://src/scripts/resources/arcade_config.gd")
const ARCADE_CONFIG_PATH := "res://resources/arcade_config.tres"

enum RunResult {
	CONTINUE,
	GAME_OVER
}

var config: ArcadeConfig
var lives: int = 3


func _ready() -> void:
	config = load(ARCADE_CONFIG_PATH)
	if config == null:
		push_error("ArcadeDirector: failed to load %s" % ARCADE_CONFIG_PATH)
		return
	lives = config.starting_lives


func start_arcade_run() -> void:
	GameSession.game_mode = GameSession.GameModes.ARCADE
	GameSession.level_name = config.starting_level_id
	lives = config.starting_lives


func can_start_run() -> bool:
	return config != null


func on_level_finished() -> String:
	return CampaignLevelLibrary.get_next_level(GameSession.level_name)


func on_player_died() -> RunResult:
	lives -= 1
	if lives <= 0:
		return RunResult.GAME_OVER
	return RunResult.CONTINUE


func reset_run() -> void:
	start_arcade_run()
