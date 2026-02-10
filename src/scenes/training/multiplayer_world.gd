class_name MultiplayerWorld
extends SubViewportContainer

@onready var level = $SubViewport/Level
@onready var player = $SubViewport/Player
@onready var camera = $SubViewport/Camera2D


func set_params(level_code: String, player_controller_type: Player.CONTROLLERS, enable_camera: bool = false) -> void:
	level.update_level(level_code)
	player.starting_position = level.player_start_position
	player.controller_type = player_controller_type
	camera.visible = enable_camera
