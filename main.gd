extends Node

@export var level: Node2D
@export var player_container: Node2D
@export var camera: Camera2D
@export var card_container: VBoxContainer
@export var level_music: AudioStreamPlayer
@export var pause_screen: MarginContainer
@export var end_screen: MarginContainer
@export var time_container: MarginContainer

@onready var player_scene = preload("res://src/scenes/player/player.tscn")
@onready var camera_scene = preload("res://src/scenes/camera_2d.tscn")
@onready var portal_scene = preload("res://src/scenes/level/tiles/portal.tscn")
var level_scene_path = "res://src/ui/menus/level_select.tscn"

var race_finished: bool = false
var first_pickup: bool = true
var total_time: float = 0.0
var delta_time: float = 0.0
var update_interval: float = 0.2

var level_name = "1-17"
var player_speed_modifier = 1.0 
var player_nodes = []

signal game_paused(is_paused: bool)


func _ready():
	level_name = GameSession.level_name if GameSession.level_name else level_name
	player_speed_modifier = GameSession.speed_modifier if GameSession.speed_modifier != 1.0 else player_speed_modifier
	
	var level_data := CampaignLevelLibrary.get_level(level_name)
	level.load_level(level_data)
	initialize_players()
	
	pause_screen.visible = false
	end_screen.visible = false
	
	SignalBus.new_run_attempt.emit(level_name)


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
	time_container.track_player(player)
	
	card_container.map_player_signals(player_nodes)


func update_players():
	var player_position = level.player_start_position
	for player: Player in player_container.get_children():
		player.starting_position = player_position
		player.speed_modifier = player_speed_modifier
		player.is_done = false
		player.reset()


func freeze_frame(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


func set_game_paused(value: bool) -> void:
	for player in player_container.get_children():
		player.is_paused = value
	pause_screen.visible = value 
	game_paused.emit(value)


func _on_player_restarted_run(_player: Player):
	reset_ui()
	SignalBus.new_run_attempt.emit(level_name)


func _on_player_finished_run(_player: Player) -> void:
	SignalBus.new_time_submission.emit(level_name, total_time)
	
	var stats = {
		"level_name": level_name,
		"time": total_time,
		"restarts": 1,
		"crowns_dropped": 0
	}
	end_screen.update_stats(stats)
	
	race_finished = true
	end_screen.visible = true
	
	for player in player_container.get_children():
		player.is_paused = true


func _on_resume_button_pressed() -> void:
	set_game_paused(false)


func _on_pause_screen_restart_button_pressed() -> void:
	for player: Player in player_container.get_children():
		player.is_done = false
		player.reset()
	#reset_ui() # TODO: check if we still need this


func _on_end_screen_restart_button_pressed() -> void:
	for player: Player in player_container.get_children():
		player.is_done = false
		player.reset()
	reset_ui()


func _on_exit_button_pressed() -> void:
	SceneLoader.go_to(level_scene_path)


func _on_next_button_pressed() -> void:
	level_name = CampaignLevelLibrary.get_next_level(level_name)
	if not level_name:
		return
	
	var level_data := CampaignLevelLibrary.get_level(level_name)
	update_level(level_data)
	reset_ui()
