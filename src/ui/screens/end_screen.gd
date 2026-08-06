extends MarginContainer

@onready var new_best_label = %NewBestLabel
@onready var level_name_label = %LevelNameLabel
@onready var current_time_label = %CurrentTimeLabel
@onready var best_time_label = %BestTimeLabel
@onready var progress_bar = %LevelProgressBar
@onready var progress_medal = %LevelProgressMedalLabel
@onready var leaderboard = %Leaderboard
@onready var next_button = %NextButton

@onready var _medal_config: MedalConfig = Constants.MEDAL_CONFIG


func _ready() -> void:
	next_button.grab_focus()


func update_stats(stats: Dictionary) -> void:
	var level_index = CampaignLevelLibrary.get_all_level_ids().find(stats["level_name"])
	var campaign_level := CampaignLevelLibrary.get_level(stats["level_name"])
	var level_name = campaign_level.display_name
	level_name_label.text = "%03d - %s" % [level_index, level_name]
	
	current_time_label.text = Utils.format_time(stats["time"])
	
	var level_data: LevelData = SaveManager.get_level_data(stats["level_name"])
	var is_first_clear = level_data.best_time == INF
	var your_best_time = "Not Done Yet" if is_first_clear else Utils.format_time(level_data.best_time)
	best_time_label.text = your_best_time
	progress_bar.value = level_data.progress_percentage
	progress_medal.text = _medal_config.medal_names[level_data.progress_milestone]
	
	new_best_label.visible = not is_first_clear and level_data.best_time == stats["time"]
	leaderboard.update_leaderboard(stats["level_name"])
