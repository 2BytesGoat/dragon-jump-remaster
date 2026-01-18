extends Node


func _ready() -> void:
	SignalBus.new_leaderboard_submission.connect(_on_new_leaderboard_submission)


func _on_new_leaderboard_submission(player_name, level_name, time) -> void:
	SilentWolf.Scores.save_score(player_name, time, level_name)
