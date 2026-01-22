extends MarginContainer

@onready var new_best_label = %NewBestLabel
@onready var level_name_label = %LevelNameLabel
@onready var current_time_label = %CurrentTimeLabel
@onready var best_time_label = %BestTimeLabel
@onready var leaderboard = %Leaderboard


func update_stats(stats: Dictionary) -> void:
	var level_index = Constants.LEVELS.keys().find(stats["level_name"])
	var level_name = Constants.LEVELS[stats["level_name"]]["name"]
	level_name_label.text = "%03d - %s" % [level_index, level_name]
	
	current_time_label.text = Utils.format_time(stats["time"])
	
	var level_data = SaveManager.get_level_data(stats["level_name"])
	best_time_label.text = Utils.format_time(level_data.best_time)
	
	new_best_label.visible = level_data.best_time == stats["time"]
	leaderboard.update_leaderboard(stats["level_name"])
