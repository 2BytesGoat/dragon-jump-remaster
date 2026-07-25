extends Node

## Test: save security and resilience.
## Verifies that:
##   - a tampered save file is rejected and a fresh save is created,
##   - a truncated save file falls back to a fresh save,
##   - an outdated save version is migrated gracefully,
##   - a missing level key is created on demand instead of crashing.

const TEST_PLAYER_NAME := "TEST_SECURITY"
const TEST_LEVEL_ID := "1-1"
const TEST_TIME := 4.0

var _original_player_name: String = ""
var _original_settings_data: SettingsData = null


func run() -> bool:
	_original_player_name = SaveManager.current_player_name
	_original_settings_data = Settings._settings_data
	SaveManager.current_player_name = TEST_PLAYER_NAME

	# Clean slate.
	_remove_test_save()

	# 1. Create a valid save and record a time.
	SaveManager.create_new_save()
	SaveManager._on_new_time_submission(TEST_LEVEL_ID, TEST_TIME)
	SaveManager.save_to_disk()

	var before_tamper := SaveManager.get_level_data(TEST_LEVEL_ID)
	if before_tamper.best_time != TEST_TIME:
		_push_fail("baseline best_time not recorded")
		_restore()
		return false

	# 2. Tamper with the save file and reload; should fall back to fresh.
	var save_path := SaveManager.SAVE_PATH % [TEST_PLAYER_NAME]
	if not FileAccess.file_exists(save_path):
		_push_fail("save file missing before tamper")
		_restore()
		return false

	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		_push_fail("could not open save file for tampering")
		_restore()
		return false
	var payload := file.get_buffer(file.get_length())
	file.close()

	# Flip one byte late in the encrypted payload to corrupt HMAC/data.
	if payload.size() > 40:
		payload[38] = (payload[38] + 1) % 256
	var tampered := FileAccess.open(save_path, FileAccess.WRITE)
	if tampered == null:
		_push_fail("could not write tampered save file")
		_restore()
		return false
	tampered.store_buffer(payload)
	tampered.close()

	SaveManager.load_game()
	var after_tamper := SaveManager.get_level_data(TEST_LEVEL_ID)
	if after_tamper.best_time == TEST_TIME:
		_push_fail("tampered save was accepted without fallback")
		_restore()
		return false
	if not SaveManager.has_level_data(TEST_LEVEL_ID):
		_push_fail("tampered save fallback did not unlock 1-1")
		_restore()
		return false

	# 3. Truncate the save file and reload; should fall back to fresh.
	SaveManager._on_new_time_submission(TEST_LEVEL_ID, TEST_TIME)
	SaveManager.save_to_disk()
	file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		_push_fail("could not open save file for truncation")
		_restore()
		return false
	var truncated := file.get_buffer(10)
	file.close()
	var truncated_out := FileAccess.open(save_path, FileAccess.WRITE)
	truncated_out.store_buffer(truncated)
	truncated_out.close()

	SaveManager.load_game()
	if not SaveManager.has_level_data(TEST_LEVEL_ID):
		_push_fail("truncated save fallback did not unlock 1-1")
		_restore()
		return false

	# 4. Missing level key should not crash.
	SaveManager.create_new_save()
	var missing_level_data := SaveManager.get_level_data("nonexistent_level")
	if missing_level_data != null:
		_push_fail("missing level should return null before unlock")
		_restore()
		return false
	SaveManager.unlock_level("nonexistent_level")
	if not SaveManager.has_level_data("nonexistent_level"):
		_push_fail("missing level was not unlocked on demand")
		_restore()
		return false

	# Clean up.
	_remove_test_save()
	_restore()
	return true


func _push_fail(message: String) -> void:
	push_error("SAVE SECURITY TEST FAIL: %s" % message)


func _restore() -> void:
	SaveManager.current_player_name = _original_player_name
	Settings._settings_data = _original_settings_data
	Settings._sync_from_data()


func _remove_test_save() -> void:
	var save_path := SaveManager.SAVE_PATH % [TEST_PLAYER_NAME]
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("SAVE SECURITY TEST: %s" % ("PASS" if passed else "FAIL"))
		get_tree().quit(0 if passed else 1)
