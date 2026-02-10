class_name MultiplayerWorld
extends SubViewportContainer

@onready var viewport = $SubViewport
@onready var level = $SubViewport/Level
@onready var player = $SubViewport/Player
@onready var camera = $SubViewport/Camera2D


func set_params(level_code: String, player_name: String, player_controller_type: Player.CONTROLLERS) -> void:
	level.update_level(level_code)
	player.starting_position = level.player_start_position
	player.name = player_name
	player.controller_type = player_controller_type


func set_camera_enabled(value: bool) -> void:
	camera.visible = value
	level.visible = value


func track_node(node_to_track: Node2D) -> void:
	camera.player_node = node_to_track
