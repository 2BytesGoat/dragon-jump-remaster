extends Node

const SAVE_PATH = "user://%s_savegame.tres"
var current_data: GameData
var current_player_name: String = Constants.DEFAULT_PLAYER_NAME : set = _on_player_name_changed


func _ready() -> void:
	load_game() # Try to load existing data first
	SignalBus.new_run_attempt.connect(_on_new_run_attempt)
	SignalBus.new_time_submission.connect(_on_new_time_submission)


func unlock_level(level_name: String):
	if not current_data.levels.has(level_name):
		var new_level = LevelData.new()
		current_data.levels[level_name] = new_level


func unlock_next_level(level_name: String):
	var next_level_name := CampaignLevelLibrary.get_next_level(level_name)
	if next_level_name == "":
		return
	unlock_level(next_level_name)


func save_to_disk():
	var save_path = SAVE_PATH % [current_player_name]
	ResourceSaver.save(current_data, save_path)


func load_game():
	var save_path = SAVE_PATH % [current_player_name]
	if ResourceLoader.exists(save_path):
		current_data = ResourceLoader.load(save_path) # Standard ResourceLoader.load works too
	if not current_data:
		create_new_save()


func create_new_save():
	current_data = GameData.new()
	current_data.player_name = current_player_name
	# Unlock the very first campaign level
	var level_ids := CampaignLevelLibrary.get_all_level_ids()
	var first_level: String = level_ids[0]
	unlock_level(first_level)
	save_to_disk()


func get_player_name() -> String:
	return current_data.player_name


func get_level_data(level_name: String) -> LevelData:
	return current_data.levels.get(level_name)


func has_level_data(level_name: String) -> bool:
	return level_name in current_data.levels


func update_level_progress(level_name: String) -> void:
	var level_data: LevelData = current_data.levels.get(level_name)
	if not level_data or level_data.best_time <= 0:
		return

	var campaign_level := CampaignLevelLibrary.get_level(level_name)
	if campaign_level == null:
		return
	var milestones := campaign_level.times
	var total_milestones = milestones.size()

	for i in range(total_milestones):
		var time_to_beat = milestones[i]
		level_data.progress_milestone = i
		if level_data.best_time <= time_to_beat:
			level_data.progress_percentage = 1.0
		else:
			level_data.progress_percentage = clamp(time_to_beat / level_data.best_time, 0.0, 1.0)
			break


func _on_new_run_attempt(level_name: String) -> void:
	var level_data: LevelData = current_data.levels.get(level_name)
	if not level_data:
		unlock_level(level_name)
		level_data = current_data.levels.get(level_name)
	level_data.attempts += 1
	save_to_disk()


func _on_new_time_submission(level_name: String, time: float) -> void:
	var level_data: LevelData = current_data.levels[level_name]
	if time != 0 and level_data.best_time > time:
		current_data.levels[level_name].best_time = time
		update_level_progress(level_name)
		unlock_next_level(level_name)
		save_to_disk()

func _on_player_name_changed(value) -> void:
	current_player_name = value
	current_data = null
	load_game() 
