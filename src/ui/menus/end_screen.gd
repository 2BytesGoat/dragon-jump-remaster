extends MarginContainer

@onready var new_best_label = %NewBestLabel
@onready var level_name_label = %LevelNameLabel
@onready var current_time_label = %CurrentTimeLabel
@onready var best_time_label = %BestTimeLabel
@onready var preogress_bar = %LevelProgressBar
@onready var progress_medal = %LevelProgressMedalLabel
@onready var leaderboard = %Leaderboard


func update_stats(stats: Dictionary) -> void:
	var level_index = Constants.LEVELS.keys().find(stats["level_name"])
	var level_name = Constants.LEVELS[stats["level_name"]]["name"]
	level_name_label.text = "%03d - %s" % [level_index, level_name]
	
	current_time_label.text = Utils.format_time(stats["time"])
	
	var level_data: LevelData = SaveManager.get_level_data(stats["level_name"])
	var your_best_time = "Not Done Yet" if level_data.best_time == INF else Utils.format_time(level_data.best_time)
	best_time_label.text = your_best_time
	preogress_bar.value = level_data.progress_percentage
	progress_medal.text = Constants.MEDAL_NAMES[level_data.progress_milestone]
	
	best_time_label.text = Utils.format_time(level_data.best_time)
	
	new_best_label.visible = level_data.best_time == stats["time"]
	leaderboard.update_leaderboard(stats["level_name"])
