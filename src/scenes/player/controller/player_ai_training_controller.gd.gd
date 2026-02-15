class_name PlayerAITrainingController
extends PlayerCharacterController

@onready var raycast_sensor_scene = preload("res://src/scenes/player/sensors/raycast_sensor.tscn")

var sensor: ISensor2D = null
var is_done: bool = false
var use_sensors: bool = false

var prev_global_position: Vector2 = Vector2.INF
var prev_value: float = INF
var best_value_ever: float = INF
var async_reward: float = 0.0


func _ready() -> void:
	if not player.level_reference:
		use_sensors = true
		sensor = raycast_sensor_scene.instantiate()
		player.add_child(sensor)
		print("AI Controller: No level reference found. Defaulting to sensor data.")
	
	SignalBus.player_finished_run.connect(_on_player_finished_run)
	add_to_group("AGENT")


func set_action(new_action: Dictionary) -> void:
	jump_command.execute(player, JumpCommand.Params.new(new_action["jump"]))


func reset() -> void:
	reset_command.execute(player)


func get_obs() -> Dictionary:
	# This is what the player unit observes in its current state
	var observations := []
	var state := []
	var direction_to_end := [0, 0]
	if use_sensors:
		state = sensor.get_observation()
	else:
		state = player.level_reference.get_surrounding_cells(player.global_position, 3)
		var direction_vector = player.global_position.direction_to(player.level_reference.exit_global_position)
		direction_to_end = [direction_vector.x, direction_vector.y]
	
	var player_velocity_vector = player.velocity.normalized()
	var velocity = [player_velocity_vector.x, player_velocity_vector.y]
	var is_on_floor = player.on_floor()
	var is_on_wall = player.on_wall()
	var perc_to_peak = player.percentage_towards_jump_peak()
	var has_powerup = int(player.has_powerups())
	
	observations.append_array(state)
	observations.append_array(direction_to_end)
	observations.append_array(velocity)
	observations.append(is_on_floor)
	observations.append(is_on_wall)
	observations.append(perc_to_peak)
	observations.append(has_powerup)
	
	return {
		"obs": observations,
		"state": state,
		"end_direction": direction_to_end,
		"velocity": velocity,
		"is_on_floor": is_on_floor,
		"is_on_wall": is_on_wall,
		"perc_to_peak": perc_to_peak,
		"has_powerup": has_powerup
	}


func get_reward() -> float:
	var curr_value = player.level_reference.get_flowfield_value(player.global_position)
	# 1. Base Time Penalty (The "Drip")
	var reward = -0.01 + async_reward
	
	# 2. Progress Reward
	# If curr_value is smaller, the agent is CLOSER to the goal.
	if curr_value < prev_value:
		reward += 0.1 # Small "good job" for moving forward
		
	# 3. New Record Bonus (Prevents vibrating back and forth)
	if curr_value < best_value_ever:
		reward += 0.5 # Larger bonus for reaching a new all-time closeness
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
		"state": player.state_machine.state.name
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


func set_done_false():
	is_done = false


func _on_player_finished_run(trigger_player: Player) -> void:
	if trigger_player == player:
		async_reward = 100
		is_done = true
