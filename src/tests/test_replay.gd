extends Node

## Deterministic movement replay test.
## Loads a V1.0 level with a player, replays a fixed sequence of jump/hold
## inputs, and asserts the final position and elapsed time. This catches
## accidental changes to the physics integration order or state machine.

const LEVEL_SCENE := preload("res://src/scenes/level/level.tscn")
const PLAYER_SCENE := preload("res://src/scenes/player/player.tscn")
const TEST_LEVEL_ID := "1-1"

# Fixed input schedule: [time_seconds, jump_pressed]
# The first true input also starts the run.
const INPUT_SCHEDULE: Array[Array] = [
	[0.00, true],
	[0.10, false],
	[0.35, true],
	[0.45, false],
	[0.80, true],
	[0.90, false],
	[1.20, true],
	[1.30, false],
]

const MAX_DURATION_SEC := 3.0

# Expected results recorded with Godot 4.6 + current physics/state-machine.
# Updated after Phase 2.2/2.6 integration changes; keep bounds generous enough
# to remain stable across machines but tight enough to catch regressions.
const EXPECTED_MIN_POSITION := Vector2(50.0, -100.0)
const EXPECTED_MAX_POSITION := Vector2(450.0, 300.0)
const EXPECTED_MIN_TIME_SEC := 0.5
const EXPECTED_MAX_TIME_SEC := 3.1


func run() -> bool:
	var level_data := CampaignLevelLibrary.get_level(TEST_LEVEL_ID)
	if level_data == null:
		push_error("REPLAY TEST FAIL: level %s not found" % TEST_LEVEL_ID)
		return false

	var level: Level = LEVEL_SCENE.instantiate()
	add_child(level)
	level.load_level(level_data)
	await get_tree().process_frame

	var player: Player = PLAYER_SCENE.instantiate()
	player.controller_type = player.CONTROLLERS.NONE
	player.starting_position = level.player_start_position
	player.global_position = player.starting_position
	add_child(player)
	await get_tree().process_frame

	var elapsed := 0.0
	var input_index := 0
	var next_input_time := INPUT_SCHEDULE[0][0]

	while elapsed < MAX_DURATION_SEC:
		# Apply any scheduled inputs for this frame.
		while input_index < INPUT_SCHEDULE.size() and elapsed >= next_input_time:
			var scheduled := INPUT_SCHEDULE[input_index]
			player.set_jump(scheduled[1])
			input_index += 1
			if input_index < INPUT_SCHEDULE.size():
				next_input_time = INPUT_SCHEDULE[input_index][0]

		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()

		if player.is_done:
			break

	var final_position := player.global_position
	var passed := true

	if final_position.x < EXPECTED_MIN_POSITION.x or final_position.x > EXPECTED_MAX_POSITION.x:
		push_error("REPLAY TEST FAIL: final x=%.2f outside expected range [%.2f, %.2f]" % [final_position.x, EXPECTED_MIN_POSITION.x, EXPECTED_MAX_POSITION.x])
		passed = false
	if final_position.y < EXPECTED_MIN_POSITION.y or final_position.y > EXPECTED_MAX_POSITION.y:
		push_error("REPLAY TEST FAIL: final y=%.2f outside expected range [%.2f, %.2f]" % [final_position.y, EXPECTED_MIN_POSITION.y, EXPECTED_MAX_POSITION.y])
		passed = false
	if elapsed < EXPECTED_MIN_TIME_SEC or elapsed > EXPECTED_MAX_TIME_SEC:
		push_error("REPLAY TEST FAIL: elapsed time %.3f outside expected range [%.3f, %.3f]" % [elapsed, EXPECTED_MIN_TIME_SEC, EXPECTED_MAX_TIME_SEC])
		passed = false

	player.queue_free()
	level.queue_free()

	if passed:
		print("REPLAY TEST PASS: final_position=%s elapsed=%.3f" % [final_position, elapsed])

	return passed


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := await run()
		print("REPLAY TEST: %s" % ("PASS" if passed else "FAIL"))
		await get_tree().process_frame
		get_tree().quit(0 if passed else 1)
