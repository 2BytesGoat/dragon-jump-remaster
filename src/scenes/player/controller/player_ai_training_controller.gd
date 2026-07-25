class_name PlayerAITrainingController
extends PlayerCharacterController

@onready var raycast_sensor_scene = preload("res://src/scenes/player/sensors/raycast_sensor.tscn")

var sensor: ISensor2D = null
var is_done: bool = false
var use_sensors: bool = false

var prev_value: float = INF
var best_value_ever: float = INF
var async_reward: float = 0.0

# Used to distinguish a synchronizer reset from a death-induced reset.
var _ignore_next_reset_signal: bool = false

# ML workshop metric: number of unique grid cells the player has touched this run
var distinct_cells_touched: Dictionary = {}


func _ready() -> void:
	if not player.level_reference:
		use_sensors = true
		sensor = raycast_sensor_scene.instantiate()
		player.add_child(sensor)
		print("AI Controller: No level reference found. Defaulting to sensor data.")
	
	player.run_finished.connect(_on_player_run_finished)
	player.has_resetted.connect(_on_player_reset)
	add_to_group("AGENT")


func set_action(new_action: Dictionary) -> void:
	jump_command.execute(player, JumpCommand.Params.new(new_action["jump"]))
	_track_distinct_cell()


func reset() -> void:
	is_done = false
	player.is_done = false
	distinct_cells_touched = {}
	prev_value = INF
	best_value_ever = INF
	async_reward = 0.0
	_ignore_next_reset_signal = true
	reset_command.execute(player)


func get_obs() -> Dictionary:
	# This is what the player unit observes in its current state
	var observations := []
	var state := []
	var direction_to_end := [0.0, 0.0]
	var distance_to_end: float = 0.0
	if use_sensors:
		state = sensor.get_observation()
	else:
		state = player.level_reference.get_surrounding_cells(player.global_position, 3)
		var direction_vector = player.global_position.direction_to(player.level_reference.exit_global_position)
		direction_to_end = [direction_vector.x, direction_vector.y]
		var flow_value = player.level_reference.get_flowfield_value(player.global_position)
		# Normalize roughly by a typical maximum level diagonal.
		distance_to_end = clamp(flow_value / 200.0, 0.0, 1.0) if flow_value != INF else 1.0
	
	var player_velocity_vector = player.velocity.normalized()
	var velocity = [player_velocity_vector.x, player_velocity_vector.y]
	var is_on_floor = player.on_floor()
	var is_on_wall = player.on_wall()
	var perc_to_peak = player.percentage_towards_jump_peak()
	var has_powerup = int(player.has_powerups())
	
	observations.append_array(state)
	observations.append_array(direction_to_end)
	observations.append(distance_to_end)
	observations.append_array(velocity)
	observations.append(is_on_floor)
	observations.append(is_on_wall)
	observations.append(perc_to_peak)
	observations.append(has_powerup)
	
	return {
		"obs": observations,
		"state": state,
		"end_direction": direction_to_end,
		"distance_to_end": distance_to_end,
		"velocity": velocity,
		"is_on_floor": is_on_floor,
		"is_on_wall": is_on_wall,
		"perc_to_peak": perc_to_peak,
		"has_powerup": has_powerup
	}


func get_reward() -> float:
	var reward := -0.01 + async_reward
	var curr_value: float = player.level_reference.get_flowfield_value(player.global_position)
	
	# 1. Penalize leaving the level bounds or unreachable areas.
	if curr_value == INF:
		reward -= 1.0
		prev_value = INF
		return reward
	
	# 2. Progress reward: scaled by how many cells closer to the exit the agent got.
	if prev_value == INF or curr_value < prev_value:
		var improvement := prev_value - curr_value if prev_value != INF else 0.0
		reward += 0.1 * clamp(improvement, 0.0, 10.0)
	
	# 3. New-record bonus for reaching a new all-time minimum distance.
	if curr_value < best_value_ever:
		reward += 0.5
		best_value_ever = curr_value
	
	prev_value = curr_value
	return reward


func get_done() -> bool:
	return is_done


func get_info() -> Dictionary:
	# These are additional information that are mainly used for debug
	var info = {
		"global_position": player.global_position,
		"facing_direction": player.facing_direction,
		"state": player.state_machine.state.name,
		"distinct_cells_touched": distinct_cells_touched.size()
	}
	if not use_sensors:
		info["tile_names"] = player.level_reference.get_tile_names()
	return info


func get_action_space() -> Dictionary:
	# This is used by the system to know how it's going to control the player
	return {
		"jump": {"size": 1, "action_type": "discrete"}
	}


func get_obs_space() -> Dictionary:
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {"size": [len(obs["obs"])], "space": "box"},
	}


func zero_reward() -> void:
	async_reward = 0.0


func _track_distinct_cell() -> void:
	if not player.level_reference:
		return
	
	var terrain_layer = player.level_reference.terrain_layer
	var cell_coords = terrain_layer.local_to_map(terrain_layer.to_local(player.global_position))
	distinct_cells_touched[cell_coords] = true


func set_done_false():
	is_done = false


func _on_player_run_finished(trigger_player: Player) -> void:
	if trigger_player == player:
		async_reward = 100.0
		is_done = true


func _on_player_reset() -> void:
	# A synchronizer reset emits this signal deliberately; ignore that one.
	if _ignore_next_reset_signal:
		_ignore_next_reset_signal = false
		return
	
	# Otherwise the player was reset by a hazard (spikes, etc.).
	async_reward = -50.0
	is_done = true
