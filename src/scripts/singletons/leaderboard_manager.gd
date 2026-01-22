extends Node

var leaderboard_cache = {}


func _ready() -> void:
	#for level_name in Constants.LEVELS:
		#SilentWolf.Scores.wipe_leaderboard(level_name)
	
	SignalBus.new_leaderboard_submission.connect(_on_new_leaderboard_submission)


func get_local_leaderboard(leaderboard_name: String):
	return leaderboard_cache.get(leaderboard_name, {})


func update_local_leaderboard(leaderboard_name: String):
	if leaderboard_cache.get(leaderboard_name, {}).get("status") == "updating":
		return
	
	var player_level_data: LevelData = SaveManager.get_level_data(leaderboard_name)
	var player_best_time = player_level_data.best_time
	
	leaderboard_cache[leaderboard_name] = {
		"status": "updating"
	}
	
	var sw_result1 = await SilentWolf.Scores.get_score_position(player_best_time).sw_get_position_complete
	var player_best_time_position = sw_result1.position
	leaderboard_cache[leaderboard_name]["player_time"] = player_best_time
	leaderboard_cache[leaderboard_name]["player_position"] = player_best_time_position
	
	var sw_result2: Dictionary = await SilentWolf.Scores.get_scores(200, leaderboard_name).sw_get_scores_complete
	var scores = sw_result2["scores"]
	for entry in scores:
		entry["score"] = float(entry["score"]) * -1
	leaderboard_cache[leaderboard_name]["scores"] = sw_result2
	leaderboard_cache[leaderboard_name]["status"] = "done"
	SignalBus.leaderboard_scores_updated.emit(leaderboard_name)


func _on_new_leaderboard_submission(player_name, level_name, time) -> void:
	SilentWolf.Scores.save_score(player_name, -1 * time, level_name)
	update_local_leaderboard(level_name)
