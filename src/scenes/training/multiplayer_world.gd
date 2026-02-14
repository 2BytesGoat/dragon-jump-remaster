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
	player.level_reference = level
	player.controller_type = player_controller_type


func set_camera_enabled(value: bool) -> void:
	camera.visible = value
	level.visible = value


func track_node(node_to_track: Node2D) -> void:
	camera.player_node = node_to_track


func compute_flow_field() -> Array:
	var level_size = level.get_level_size_cell()
	var level_cost = level.get_level_costs()
	var exit_cell = level.get_exit_cell_coords()
	return Utils.generate_dijkstra_map(level_size, level_cost, exit_cell)


func set_flow_field(flow_field: Array) -> void:
	level.flow_field = flow_field
