extends Node

## ArcadeDirector
## Central controller for arcade mode setup, life tracking, run progression,
## and run summary for the local arcade leaderboard.
const ARCADE_CONFIG_PATH := "res://resources/arcade_config.tres"

enum RunResult {
	CONTINUE,
	GAME_OVER
}

signal run_ended(summary: Dictionary)

var config: ArcadeConfig
var lives: int = 3
var score: int = 0
var levels_reached: int = 1
var player_tag: String = ""


func _ready() -> void:
	config = load(ARCADE_CONFIG_PATH)
	if config == null:
		push_error("ArcadeDirector: failed to load %s" % ARCADE_CONFIG_PATH)
		return
	_reset_run_state()


func start_arcade_run() -> void:
	_reset_run_state()
	GameSession.set_game_mode(GameSession.GameModes.ARCADE)
	GameSession.level_name = config.starting_level_id


func can_start_run() -> bool:
	return config != null


func on_level_finished() -> String:
	score += config.level_clear_score
	var next_level := CampaignLevelLibrary.get_next_level(GameSession.level_name)
	if next_level.is_empty():
		_end_run()
		return ""
	GameSession.level_name = next_level
	levels_reached += 1
	return next_level


func on_player_died() -> RunResult:
	lives -= 1
	if lives <= 0:
		_end_run()
		return RunResult.GAME_OVER
	return RunResult.CONTINUE


var _run_ended: bool = false
var _run_to_submit: bool = false


func submit_tag(tag: String) -> void:
	player_tag = tag
	_run_ended = false
	if _run_to_submit and score > 0:
		SaveManager.submit_arcade_run(tag, score, levels_reached)
	_run_to_submit = false


func skip_run_submission() -> void:
	player_tag = ""
	_run_ended = false
	_run_to_submit = false


func has_run_to_submit() -> bool:
	return _run_to_submit and player_tag.is_empty()


func get_run_summary() -> Dictionary:
	return {
		"tag": player_tag,
		"score": score,
		"levels_reached": levels_reached,
		"final_level": GameSession.level_name
	}


func _reset_run_state() -> void:
	lives = config.starting_lives if config != null else 3
	score = 0
	levels_reached = 1
	player_tag = ""
	_run_ended = false
	_run_to_submit = false


func _end_run() -> void:
	_run_ended = true
	_run_to_submit = true
	run_ended.emit(get_run_summary())
