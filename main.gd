extends Node

@export var level: Node2D
@export var player_container: Node2D
@export var camera: Camera2D
@export var screen_shake: ScreenShake
@export var hit_stop: HitStop
@export var card_container: VBoxContainer
@export var level_music: AudioStreamPlayer
@export var pause_screen: MarginContainer
@export var end_screen: MarginContainer
@export var time_container: MarginContainer
@export var transition_wipe: TransitionWipe

@onready var player_scene = preload("res://src/scenes/player/player.tscn")
@onready var camera_scene = preload("res://src/scenes/camera_2d.tscn")
@onready var portal_scene = preload("res://src/scenes/level/tiles/portal.tscn")
var level_scene_path = "res://src/ui/menus/level_select.tscn"

var race_finished: bool = false
var first_pickup: bool = true
var total_time: float = 0.0
var delta_time: float = 0.0
var update_interval: float = 0.2

var level_name = "tmp"
var player_speed_modifier = 1.0 
var player_nodes = []

signal game_paused(is_paused: bool)

const TMP_PREVIEW_PATH := "res://resources/level_data/_editor_preview.tres"


func _ready():
	level_name = GameSession.level_name if GameSession.level_name else level_name
	player_speed_modifier = GameSession.speed_modifier if GameSession.speed_modifier != 1.0 else player_speed_modifier
	
	var level_data := CampaignLevelLibrary.get_level(level_name)
	level.load_level(level_data)
	initialize_players()
	
	pause_screen.visible = false
	end_screen.visible = false
	
	SignalBus.new_run_attempt.emit(level_name)
	TelemetrySystem.level_started(level_name)


func update_level(level_data: CampaignLevelData):
	level.load_level(level_data)
	update_players()


func reset_ui():
	set_game_paused(false)
	time_container.reset()
	race_finished = false
	end_screen.visible = false


func _input(event: InputEvent) -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if not race_finished and event.is_action_pressed("ui_cancel"):
		if pause_screen.visible and pause_screen.has_method("close_settings_if_open"):
			pause_screen.close_settings_if_open()
		else:
			set_game_paused(not pause_screen.visible)


func initialize_players() -> void:
	var player_position = level.player_start_position
	var player: Player = player_scene.instantiate()
	player.controller_type = player.CONTROLLERS.PLAYER_ONE
	camera.player_node = player
	
	player.name = "Player1"
	player.starting_position = player_position
	player.speed_modifier = player_speed_modifier
	player_container.add_child(player)
	player_nodes.append(player)
	
	player.has_resetted.connect(level.reset_objects)
	player.run_restarted.connect(_on_player_restarted_run)
	player.run_finished.connect(_on_player_finished_run)
	player.died.connect(_on_player_died)
	player.powerup_consumed.connect(_on_player_used_powerup)
	player.screen_shake = screen_shake
	player.hit_stop = hit_stop
	player.transition_wipe = transition_wipe
	player.camera = camera
	time_container.track_player(player)
	
	card_container.map_player_signals(player_nodes)


func update_players():
	var player_position = level.player_start_position
	var current_players := player_container.get_children()
	for player: Player in current_players:
		player.starting_position = player_position
		player.speed_modifier = player_speed_modifier
		player.is_done = false
		player.reset()


func set_game_paused(value: bool) -> void:
	for player in player_container.get_children():
		player.is_paused = value
	pause_screen.visible = value 
	game_paused.emit(value)


func _on_player_restarted_run(_player: Player):
	if race_finished:
		return
	reset_ui()
	SignalBus.new_run_attempt.emit(level_name)
	TelemetrySystem.run_restarted(level_name)


func _on_player_finished_run(player: Player) -> void:
	match GameSession.game_mode:
		GameSession.GameModes.PRACTICE:
			_on_player_finished_practice_run(player)
		GameSession.GameModes.ARCADE:
			_on_arcade_level_finished()


func _on_player_died(_player: Player) -> void:
	if GameSession.game_mode != GameSession.GameModes.ARCADE:
		return
	var result := ArcadeDirector.on_player_died()
	if result == ArcadeDirector.RunResult.GAME_OVER:
		_show_arcade_game_over()


func _on_player_used_powerup(_type: String) -> void:
	screen_shake.shake(ScreenShake.Event.POWERUP)


func _show_arcade_game_over() -> void:
	race_finished = true
	for p in player_container.get_children():
		p.is_paused = true
	# TODO: show 3-letter tag entry + arcade leaderboard
	#       ArcadeDirector.get_run_summary() contains the run data to display.


func _on_player_finished_practice_run(_player: Player) -> void:
	SignalBus.new_time_submission.emit(level_name, total_time)
	TelemetrySystem.level_finished(level_name, total_time)
	
	var stats = {
		"level_name": level_name,
		"time": total_time,
		"restarts": 1
	}
	end_screen.update_stats(stats)
	
	race_finished = true
	end_screen.visible = true
	
	for player in player_container.get_children():
		player.is_paused = true


func _on_resume_button_pressed() -> void:
	set_game_paused(false)


func _on_pause_screen_restart_button_pressed() -> void:
	reset_ui()
	for player: Player in player_container.get_children():
		player.is_done = false
		player.reset()


func _on_end_screen_restart_button_pressed() -> void:
	for player: Player in player_container.get_children():
		player.is_done = false
		player.reset()
	reset_ui()


func _on_exit_button_pressed() -> void:
	TelemetrySystem.menu_opened("level_select")
	SceneLoader.go_to(level_scene_path)


func _on_next_button_pressed() -> void:
	_progress_to_next_level()


func _on_arcade_level_finished() -> void:
	level_name = ArcadeDirector.on_level_finished()
	if ArcadeDirector.has_run_to_submit():
		_show_arcade_game_over()
		return
	
	var level_data := CampaignLevelLibrary.get_level(level_name)
	update_level(level_data)
	reset_ui()


func _progress_to_next_level() -> void:
	level_name = CampaignLevelLibrary.get_next_level(level_name)
	if not level_name:
		# TODO: add final end screen to show
		return 
	
	var level_data := CampaignLevelLibrary.get_level(level_name)
	update_level(level_data)
	reset_ui()
