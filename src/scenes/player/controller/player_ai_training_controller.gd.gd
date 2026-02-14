class_name PlayerAITrainingController
extends PlayerCharacterController

@onready var raycast_sensor_scene = preload("res://src/scenes/player/sensors/raycast_sensor.tscn")

var sensor: ISensor2D = null
var is_done: bool = false
var reward: float = 0.0
var use_sensors: bool = false


func _ready() -> void:
	if not player.level_reference:
		use_sensors = true
		sensor = raycast_sensor_scene.instantiate()
		player.add_child(sensor)
		print("AI Controller: No level reference found. Defaulting to sensor data.")
	
	add_to_group("AGENT")


func set_action(new_action: Dictionary) -> void:
	jump_command.execute(player, JumpCommand.Params.new(new_action["jump"]))


func reset() -> void:
	reset_command.execute(player)


func get_obs() -> Dictionary:
	# This is what the player unit observes in its current state
	var observations := []
	var direction_to_end := Vector2.ZERO
	if use_sensors:
		observations = sensor.get_observation()
	else:
		observations = player.level_reference.get_surrounding_cells(player.global_position, 3)
		direction_to_end = player.global_position.direction_to(player.level_reference.finish_global_position)
	
	var player_velocity_vector = player.velocity.normalized()
	return {
		"obs": observations,
		"end_direction": [direction_to_end.x, direction_to_end.y],
		"velocity": [player_velocity_vector.x, player_velocity_vector.y],
		"is_on_floor": player.on_floor(),
		"is_on_wall": player.on_wall(),
		"perc_to_peak": player.percentage_towards_jump_peak(),
		"has_powerup": int(player.has_powerups())
	}


func get_reward() -> float:
	# This is how much the player earned for its past action
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
	reward = 0.0
