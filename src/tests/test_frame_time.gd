extends Node

## Frame-time smoke test.
## Loads a V1.0 level with a player and verifies the simulation stays within a
## reasonable frame budget for the first 30 seconds of gameplay. Runs as an
## async scene so it can be executed standalone or from an async-aware runner.

const LEVEL_SCENE := preload("res://src/scenes/level/level.tscn")
const PLAYER_SCENE := preload("res://src/scenes/player/player.tscn")
const TEST_LEVEL_ID := "1-1"

# Target: 60 fps = ~16.67 ms per frame. We allow a small headless tolerance.
const MAX_FRAME_TIME_SEC := 0.033  # 30 fps worst-case spike
const AVG_FRAME_TIME_SEC := 0.02   # 50 fps average
const GAMEPLAY_DURATION_SEC := 30.0
const MAX_LOAD_TIME_SEC := 1.0


func run() -> bool:
	var level_data := CampaignLevelLibrary.get_level(TEST_LEVEL_ID)
	if level_data == null:
		push_error("FRAME TIME TEST FAIL: level %s not found" % TEST_LEVEL_ID)
		return false

	var level: Level = LEVEL_SCENE.instantiate()
	add_child(level)

	# Measure level load time.
	var load_start_us := Time.get_ticks_usec()
	level.load_level(level_data)
	await get_tree().process_frame
	var load_dt := (Time.get_ticks_usec() - load_start_us) / 1_000_000.0

	if load_dt > MAX_LOAD_TIME_SEC:
		push_error("FRAME TIME TEST FAIL: level load took %.3f s" % load_dt)
		level.queue_free()
		return false

	# Spawn a player so gameplay physics/AI are exercised.
	var player: Player = PLAYER_SCENE.instantiate()
	player.controller_type = player.CONTROLLERS.PLAYER_ONE
	player.starting_position = level.player_start_position
	player.global_position = player.starting_position
	add_child(player)

	# Warm-up frame before measurement.
	await get_tree().process_frame

	var elapsed := 0.0
	var frame_count := 0
	var total_frame_time := 0.0
	var max_frame_time := 0.0

	while elapsed < GAMEPLAY_DURATION_SEC:
		var frame_start_us := Time.get_ticks_usec()
		await get_tree().process_frame
		var frame_dt := (Time.get_ticks_usec() - frame_start_us) / 1_000_000.0

		total_frame_time += frame_dt
		max_frame_time = max(max_frame_time, frame_dt)
		elapsed += frame_dt
		frame_count += 1

	player.queue_free()
	level.queue_free()

	var avg_frame_time := total_frame_time / float(max(frame_count, 1))
	var passed: bool = avg_frame_time <= AVG_FRAME_TIME_SEC and max_frame_time <= MAX_FRAME_TIME_SEC

	if not passed:
		push_error(
			"FRAME TIME TEST FAIL: avg=%.3f ms, max=%.3f ms over %d frames" % [
				avg_frame_time * 1000.0,
				max_frame_time * 1000.0,
				frame_count
			]
		)
	else:
		print(
			"FRAME TIME TEST PASS: avg=%.3f ms, max=%.3f ms over %d frames" % [
				avg_frame_time * 1000.0,
				max_frame_time * 1000.0,
				frame_count
			]
		)

	return passed


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := await run()
		print("FRAME TIME TEST: %s" % ("PASS" if passed else "FAIL"))
		await get_tree().process_frame
		get_tree().quit(0 if passed else 1)
