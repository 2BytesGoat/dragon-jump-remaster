extends Node

## Test Runner
## Loads each focused test, runs it, and reports a combined result.
## Designed to be executed headlessly as the main scene:
##   godot --headless --script test_runner.gd  (or as scene main scene)

const TEST_SCENES: Array[PackedScene] = [
	preload("res://src/tests/test_boot.tscn"),
	preload("res://src/tests/test_level_load.tscn"),
	preload("res://src/tests/test_save_score.tscn"),
]


func _ready() -> void:
	var all_passed := true

	for scene in TEST_SCENES:
		var test: Node = scene.instantiate()
		add_child(test)
		
		var passed: bool
		if test.has_method("run"):
			passed = test.run()
		else:
			push_error("TEST RUNNER: %s is missing run()" % scene.resource_path)
			passed = false
		
		remove_child(test)
		test.queue_free()
		
		if not passed:
			all_passed = false
			push_error("TEST RUNNER FAIL: %s" % scene.resource_path)

	if all_passed:
		print("ALL TESTS PASS")
	else:
		push_error("ONE OR MORE TESTS FAILED")

	get_tree().quit(0 if all_passed else 1)
