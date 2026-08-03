extends Node

## Test Runner
## Loads each focused test, runs it, and reports a combined result.
## Designed to be executed headlessly as the main scene:
##   godot --headless --script test_runner.gd  (or as scene main scene)

const TEST_SCENES: Array[PackedScene] = [
	preload("res://src/tests/test_boot.tscn"),
	preload("res://src/tests/test_level_load.tscn"),
	preload("res://src/tests/test_save_score.tscn"),
	preload("res://src/tests/test_save_security.tscn"),
	preload("res://src/tests/test_arcade_leaderboard.tscn"),
	preload("res://src/tests/test_frame_time.tscn"),
	preload("res://src/tests/test_replay.tscn"),
]


func _ready() -> void:
	var all_passed := await _run_tests()

	if all_passed:
		print("ALL TESTS PASS")
	else:
		push_error("ONE OR MORE TESTS FAILED")

	get_tree().quit(0 if all_passed else 1)


func _run_tests() -> bool:
	var all_passed := true

	for scene in TEST_SCENES:
		var test: Node = scene.instantiate()
		add_child(test)

		var passed: bool = await _run_single(test)

		remove_child(test)
		test.queue_free()
		# Give the engine a frame to actually free the test node before shutdown.
		await get_tree().process_frame

		if not passed:
			all_passed = false
			push_error("TEST RUNNER FAIL: %s" % scene.resource_path)

	return all_passed


func _run_single(test: Node) -> bool:
	if not test.has_method("run"):
		push_error("TEST RUNNER: %s is missing run()" % test.scene_file_path)
		return false

	# Synchronous tests return bool; the frame-time test is a coroutine.
	return await test.run()
