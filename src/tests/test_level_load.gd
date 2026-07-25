extends Node

## Test: each V1.0 campaign level loads from symbol code.
## Iterates over all non-hidden CampaignLevelData resources, instantiates a
## Level node, calls load_level(), and verifies a positive size and a non-zero
## player start position.

const LEVEL_SCENE := preload("res://src/scenes/level/level.tscn")


func run() -> bool:
	var all_passed := true
	var level_ids := CampaignLevelLibrary.get_all_level_ids()

	for level_id in level_ids:
		var level_data := CampaignLevelLibrary.get_level(level_id)
		if level_data == null or level_data.hidden:
			continue

		var level: Level = LEVEL_SCENE.instantiate()
		add_child(level)
		level.load_level(level_data)

		var size_ok := level.get_level_size_cell().x > 0
		var start_ok := level.player_start_position != Vector2.ZERO
		if not size_ok or not start_ok:
			push_error("LEVEL LOAD TEST FAIL for %s: size=%s start=%s" % [level_id, size_ok, start_ok])
			all_passed = false

		level.queue_free()

	return all_passed


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("LEVEL LOAD TEST: %s" % ("PASS" if passed else "FAIL"))
		await get_tree().process_frame
		get_tree().quit(0 if passed else 1)
