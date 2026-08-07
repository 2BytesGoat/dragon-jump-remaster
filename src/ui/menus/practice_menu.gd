extends MarginContainer

## PracticeMenu
## Level picker for practice runs: browse campaign levels, preview them in a
## SubViewport, tune player speed, and start a run by pressing JUMP.

signal closed

const GAME_SCENE_PATH := "res://main.tscn"

@onready var level_button_container = %LevelButtonContainer
@onready var level_node = %Level
@onready var selected_level_label = %SelectedLevelLabel
@onready var speed_slider = %SpeedSlider
@onready var your_best_time_label = %YourBestTimeLabel
@onready var level_progress_bar = %LevelProgressBar
@onready var level_progress_medal = %LevelProgressMedalLabel
@onready var level_attempts_label = %LevelAttemptsLabel

@onready var level_button_scene = preload("res://src/ui/components/level_button.tscn")

var selected_level_name = ""

@onready var _medal_config: MedalConfig = Constants.MEDAL_CONFIG


func _ready() -> void:
	TelemetrySystem.menu_opened("practice")
	for child in level_button_container.get_children():
		level_button_container.remove_child(child)
		child.queue_free()

	var display_index = 0
	var level_ids := CampaignLevelLibrary.get_all_level_ids()
	for i in len(level_ids):
		var level_name = level_ids[i]
		var level_data := CampaignLevelLibrary.get_level(level_name)
		if level_data.hidden:
			continue

		var button: Button = level_button_scene.instantiate()
		button.name = level_name
		level_button_container.add_child(button)
		button.set_button_disabled(not SaveManager.has_level_data(level_name))
		button.button_label = "%03d - %s" % [display_index, level_data.display_name]
		button.pressed.connect(_on_level_button_clicked.bind(level_name))
		button.hovered.connect(_on_level_button_hovered)

		if display_index == 0:
			selected_level_name = level_name
			_update_level_display(level_name)
			button.grab_focus()
		display_index += 1


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("player_one_jump"):
		get_viewport().set_input_as_handled()
		_start_run()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()


func focus_first_level() -> void:
	var first_button := level_button_container.get_child(0)
	if first_button is Button:
		first_button.grab_focus()


func _on_level_button_hovered(level_name: String) -> void:
	selected_level_name = level_name
	_update_level_display(level_name)


func _on_level_button_clicked(level_name: String) -> void:
	selected_level_name = level_name
	_update_level_display(level_name)
	_start_run()


func _update_level_display(level_name: String) -> void:
	var campaign_level := CampaignLevelLibrary.get_level(level_name)
	level_node.load_level(campaign_level)

	var level_data: LevelData = SaveManager.get_level_data(level_name)
	var your_best_time = "Not Done Yet" if level_data.best_time == INF else Utils.format_time(level_data.best_time)
	your_best_time_label.text = your_best_time

	level_attempts_label.text = str(level_data.attempts)

	level_progress_bar.value = level_data.progress_percentage
	level_progress_medal.text = _medal_config.medal_names[level_data.progress_milestone]

	var i = CampaignLevelLibrary.get_all_level_ids().find(level_name)
	selected_level_label.text = "%03d - %s" % [i, campaign_level.display_name]


func _start_run() -> void:
	if not selected_level_name:
		return
	var speed_modifier = 0.75 + speed_slider.value * 0.25
	GameSession.start_run(selected_level_name, speed_modifier)
	SceneLoader.go_to(GAME_SCENE_PATH)
