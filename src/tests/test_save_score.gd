extends Node

## Test: finish a run, save the score, reload it.
## Switches to a temporary player profile, submits a time for 1-1, saves,
## reloads, and verifies the best time and unlocked next level persist.

const TEST_PLAYER_NAME := "TEST_SAVE"
const TEST_LEVEL_ID := "1-1"
const TEST_TIME := 5.0

var _original_player_name: String = ""


func run() -> bool:
	_original_player_name = SaveManager.current_player_name

	# Switch to an isolated test profile.
	SaveManager.current_player_name = TEST_PLAYER_NAME
	SaveManager.create_new_save()

	if not SaveManager.has_level_data(TEST_LEVEL_ID):
		_push_fail("test level was not unlocked for new save")
		_restore_player_name()
		return false

	# Simulate finishing a run with a valid time.
	SaveManager._on_new_time_submission(TEST_LEVEL_ID, TEST_TIME)
	SaveManager.save_to_disk()

	var before_reload := SaveManager.get_level_data(TEST_LEVEL_ID)
	if before_reload.best_time != TEST_TIME:
		_push_fail("best_time was not updated before reload: %s" % before_reload.best_time)
		_restore_player_name()
		return false

	var next_level := CampaignLevelLibrary.get_next_level(TEST_LEVEL_ID)
	if next_level != "" and not SaveManager.has_level_data(next_level):
		_push_fail("next level (%s) was not unlocked before reload" % next_level)
		_restore_player_name()
		return false

	# Reload from disk and verify persistence.
	SaveManager.load_game()
	var after_reload := SaveManager.get_level_data(TEST_LEVEL_ID)
	if after_reload.best_time != TEST_TIME:
		_push_fail("best_time was not persisted after reload: %s" % after_reload.best_time)
		_restore_player_name()
		return false

	if next_level != "" and not SaveManager.has_level_data(next_level):
		_push_fail("next level (%s) was not persisted after reload" % next_level)
		_restore_player_name()
		return false

	# Clean up the temporary save file and restore the original profile.
	_remove_test_save()
	_restore_player_name()
	return true


func _push_fail(message: String) -> void:
	push_error("SAVE SCORE TEST FAIL: %s" % message)


func _restore_player_name() -> void:
	SaveManager.current_player_name = _original_player_name


func _remove_test_save() -> void:
	var save_path := "user://%s_savegame.tres" % TEST_PLAYER_NAME
	if ResourceLoader.exists(save_path):
		DirAccess.remove_absolute(save_path)


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("SAVE SCORE TEST: %s" % ("PASS" if passed else "FAIL"))
		get_tree().quit(0 if passed else 1)
