class_name PlayerAITrainingController
extends PlayerCharacterController

@onready var raycast_sensor_scene = preload("res://src/scenes/player/sensors/raycast_sensor.tscn")

var sensor: ISensor2D = null
var is_done: bool = false


func _ready() -> void:
	sensor = raycast_sensor_scene.instantiate()
	player.add_child(sensor)
	add_to_group("AGENT")


func set_action(new_action: bool) -> void:
	jump_command.execute(player, JumpCommand.Params.new(new_action))


func reset() -> void:
	reset_command.execute(player)


func get_obs() -> Dictionary:
	# This is what the player unit observes in its current state
	var observations = sensor.get_observation()
	return {"obs": observations}


func get_reward() -> float:
	# This is how much the player earned for its past action
	return 0.0


func get_info() -> Dictionary:
	# These are additional information that are mainly used for debug
	return {}


func get_action_space() -> Dictionary:
	# This is used by the system to know how it's going to control the player
	return {"size": 1, "action_type": "discrete"}


func get_obs_space() -> Dictionary:
	# may need overriding if the obs space is complex
	var obs = get_obs()
	return {
		"obs": {"size": [len(obs["obs"])], "space": "box"},
	}
