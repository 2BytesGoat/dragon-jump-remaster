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
signal level_rank_awarded(level_id: String, rank: String, multiplier: float, bonus: int)
signal run_multiplier_changed(multiplier: float)

var config: ArcadeConfig
var lives: int = 3
var score: int = 0
var levels_reached: int = 1
var player_tag: String = ""
var run_multiplier: float = 1.0
var _level_bonuses: Array[Dictionary] = []


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


func on_level_finished(level_time: float) -> String:
	var level_id := GameSession.level_name
	var campaign_level := CampaignLevelLibrary.get_level(level_id)
	var bronze: float = INF
	var silver: float = INF
	var gold: float = INF
	if campaign_level != null and not campaign_level.times.is_empty():
		bronze = campaign_level.times[0]
		gold = campaign_level.times[-1]
		silver = campaign_level.times[1] if campaign_level.times.size() >= 3 else gold
	var time_multiplier := calculate_time_multiplier(level_time, bronze, silver, gold, config)
	var bonus := roundi(config.level_clear_score * time_multiplier * run_multiplier)
	_streak_apply()
	level_rank_awarded.emit(level_id, _rank_for_multiplier(time_multiplier), run_multiplier, bonus)
	if bonus > 0:
		score += bonus
		_level_bonuses.append({"level_id": level_id, "time": level_time, "multiplier": run_multiplier, "bonus": bonus})
	var next_level := CampaignLevelLibrary.get_next_level(GameSession.level_name)
	if next_level.is_empty():
		_end_run()
		return ""
	GameSession.level_name = next_level
	levels_reached += 1
	return next_level


func on_player_died() -> RunResult:
	_reset_run_multiplier()
	lives -= 1
	if lives <= 0:
		_end_run()
		return RunResult.GAME_OVER
	return RunResult.CONTINUE


func _streak_apply() -> void:
	run_multiplier += 1.0
	run_multiplier_changed.emit(run_multiplier)


func _reset_run_multiplier() -> void:
	if run_multiplier != 1.0:
		run_multiplier = 1.0
		run_multiplier_changed.emit(run_multiplier)


static func calculate_time_multiplier(level_time: float, bronze: float, silver: float, gold: float, config: ArcadeConfig) -> float:
	if config == null:
		return 1.0
	var min_multiplier := config.bronze_multiplier
	var silver_multiplier := config.silver_multiplier
	var gold_multiplier := config.gold_multiplier
	var max_multiplier := config.max_multiplier
	if level_time >= bronze:
		return min_multiplier
	if level_time >= silver:
		return lerpf(min_multiplier, silver_multiplier, (bronze - level_time) / maxf(bronze - silver, 0.0001))
	if level_time >= gold:
		return lerpf(silver_multiplier, gold_multiplier, (silver - level_time) / maxf(silver - gold, 0.0001))
	return lerpf(gold_multiplier, max_multiplier, (gold - level_time) / maxf(gold, 0.0001))


static func _rank_for_multiplier(multiplier: float) -> String:
	if multiplier >= 3.0:
		return "GOLD+"
	if multiplier >= 2.0:
		return "GOLD"
	if multiplier >= 1.5:
		return "SILVER"
	if multiplier > 1.0:
		return "BRONZE"
	return ""


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
		"final_level": GameSession.level_name,
		"bonus_total": _sum_level_bonuses(),
		"bonuses": _level_bonuses.duplicate(),
	}


func _sum_level_bonuses() -> int:
	var total := 0
	for entry in _level_bonuses:
		total += int(entry.get("bonus", 0))
	return total


func _reset_run_state() -> void:
	lives = config.starting_lives if config != null else 3
	score = 0
	levels_reached = 1
	player_tag = ""
	run_multiplier = 1.0
	_level_bonuses = []
	_run_ended = false
	_run_to_submit = false


func _end_run() -> void:
	_run_ended = true
	_run_to_submit = true
	run_ended.emit(get_run_summary())
