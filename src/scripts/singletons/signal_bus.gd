extends Node

signal player_started_run(player)
signal player_restarted_run(player)
signal player_touched_crown(player)
signal player_dropped_crown(player)
signal player_finished_run(player)
signal new_run_attempt(level_name)
signal new_time_submission(level_name, time)
signal new_leaderboard_submission(player_name: String, level_name:String, time:float)
signal race_finish_position_updated(new_global_position)
