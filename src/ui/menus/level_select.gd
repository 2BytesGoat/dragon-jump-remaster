extends MarginContainer

@onready var level_button_container = %LevelButtonContainer
@onready var level_node = %Level
@onready var selected_level_label = %SelectedLevelLabel
@onready var speed_slider = %SpeedSlider
@onready var your_best_time_label = %YourBestTimeLabel
@onready var level_progress_bar = %LevelProgressBar
@onready var level_progress_medal = %LevelProgressMedalLabel
@onready var level_attempts_label = %LevelAttemptsLabel

@onready var level_info_container = %LevelInfoContainer
@onready var leaderboard_container = %LeaderboardContainer
@onready var leaderboard = %Leaderboard

@onready var level_button_scene = preload("res://src/ui/menus/level_button.tscn")
@export var single_player_scene: PackedScene
@export var main_menu_scene: PackedScene

var selected_level_name = ""


func _ready() -> void:
	var cnt = 0
	
	for child in level_button_container.get_children():
		level_button_container.remove_child(child)
		child.queue_free()
	
	for i in len(Constants.LEVELS):
		var level_name = Constants.LEVELS.keys()[i]
		var button: Button = level_button_scene.instantiate()
		button.name = level_name
		level_button_container.add_child(button)
		button.set_button_disabled(not SaveManager.has_level_data(level_name))
		button.button_label = "%03d - %s" % [i, Constants.LEVELS[level_name]["name"]]
		button.pressed.connect(_on_level_button_clicked.bind(level_name))
		
		if cnt == 0:
			_on_level_button_clicked(level_name)
			button.grab_focus()
		cnt += 1
	
	_on_map_info_button_pressed()


func _on_level_button_hovered(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	level_node.update_level(level_code)


func _on_level_button_clicked(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	level_node.update_level(level_code)
	selected_level_name = level_name
	
	var level_data: LevelData = SaveManager.get_level_data(level_name)
	var your_best_time = "Not Done Yet" if level_data.best_time == INF else Utils.format_time(level_data.best_time)
	your_best_time_label.text = your_best_time
	
	level_attempts_label.text = str(level_data.attempts)
	
	level_progress_bar.value = level_data.progress_percentage
	level_progress_medal.text = Constants.MEDAL_NAMES[level_data.progress_milestone]
	
	var i = Constants.LEVELS.keys().find(level_name)
	selected_level_label.text = "%03d - %s" % [i, Constants.LEVELS[level_name]["name"]]
	
	if leaderboard_container.visible:
		_on_map_info_button_pressed()


func _on_start_button_pressed() -> void:
	if not selected_level_name:
		return
	var speed_modifier = speed_slider.value + 0.5
	
	SceneManger.go_to(single_player_scene.resource_path, {"level_name": selected_level_name, "speed_modifier": speed_modifier})


func _on_back_button_pressed() -> void:
	SceneManger.go_to(main_menu_scene.resource_path)


func _on_leaderboard_button_pressed() -> void:
	level_info_container.visible = false
	leaderboard_container.visible = true
	leaderboard.update_leaderboard(selected_level_name)


func _on_map_info_button_pressed() -> void:
	level_info_container.visible = true
	leaderboard_container.visible = false
