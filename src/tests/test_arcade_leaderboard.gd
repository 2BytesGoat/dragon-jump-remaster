extends Node

## Test: arcade leaderboard persistence.
## Uses a temporary player profile, submits arcade runs out of score order,
## reloads from disk, and verifies the top-10 leaderboard stays sorted
## descending and that the high score is reported correctly.

const TEST_PLAYER_NAME := "TEST_ARCADE"
const TEST_TAG := "ACE01"
const TEST_LEVEL_ID := "1-1"

var _original_player_name: String = ""
var _original_settings_data: SettingsData = null


func run() -> bool:
	_original_player_name = SaveManager.current_player_name
	_original_settings_data = Settings._settings_data

	# Switch to an isolated test profile.
	SaveManager.current_player_name = TEST_PLAYER_NAME
	SaveManager.create_new_save()

	if not SaveManager.get_arcade_leaderboard().is_empty():
		_push_fail("leaderboard should start empty")
		_restore()
		return false

	# Submit runs out of score order; #2 has the best score, #3 ties #1 but
	# clears more levels.
	SaveManager.submit_arcade_run("ZZTOP", 500, 2)
	SaveManager.submit_arcade_run(TEST_TAG, 9000, 5)
	SaveManager.submit_arcade_run("NEO", 500, 3)
	SaveManager.submit_arcade_run("ACE", 1000, 1)
	SaveManager.save_to_disk()

	# Reload from disk and verify persistence.
	SaveManager.load_game()
	var entries := SaveManager.get_arcade_leaderboard()
	if entries.size() != 4:
		_push_fail("expected 4 persisted entries, got %d" % entries.size())
		_restore()
		return false

	if entries[0].get("tag", "") != TEST_TAG:
		_push_fail("top entry should be %s, got %s" % [TEST_TAG, entries[0].get("tag", "")])
		_restore()
		return false

	if int(entries[0].get("score", 0)) != 9000:
		_push_fail("top score should be 9000, got %s" % entries[0].get("score", 0))
		_restore()
		return false

	if int(entries[2].get("score", 0)) != 500 or int(entries[2].get("levels", 0)) != 3:
		_push_fail("tie-break should favor more levels at same score")
		_restore()
		return false

	if SaveManager.get_arcade_high_score() != 9000:
		_push_fail("high score should be 9000, got %d" % SaveManager.get_arcade_high_score())
		_restore()
		return false

	# Verify trimming: submit 12 runs, expect exactly 10 kept, best first.
	for i in range(12):
		SaveManager.submit_arcade_run("TST%02d" % i, 100 + i, 1)
	var trimmed := SaveManager.get_arcade_leaderboard()
	if trimmed.size() != 10:
		_push_fail("leaderboard should trim to 10, got %d" % trimmed.size())
		_restore()
		return false

	if int(trimmed[0].get("score", 0)) != 9111:
		_push_fail("after trimming, top score should be 9111, got %d" % int(trimmed[0].get("score", 0)))
		_restore()
		return false

	# Clean up the temporary save file and restore the original profile.
	_remove_test_save()
	_restore()
	return true


func _push_fail(message: String) -> void:
	push_error("ARCADE LEADERBOARD TEST FAIL: %s" % message)


func _restore() -> void:
	SaveManager.current_player_name = _original_player_name
	Settings._settings_data = _original_settings_data
	Settings._sync_from_data()


func _remove_test_save() -> void:
	var save_path := "user://%s_savegame.bin" % TEST_PLAYER_NAME
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("ARCADE LEADERBOARD TEST: %s" % ("PASS" if passed else "FAIL"))
		get_tree().quit(0 if passed else 1)
