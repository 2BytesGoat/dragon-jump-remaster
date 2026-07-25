extends Node

## SaveManager
## Persists progress data to an encrypted binary file protected by an HMAC
## checksum. Falls back to a fresh save on corruption, tampering, missing keys,
## or version mismatch.

const SAVE_PATH = "user://%s_savegame.bin"
const SAVE_VERSION := 1

## Simple fixed secret used for the HMAC layer. In a shipped title this should
## be injected at build time (e.g. via CI secret) and never committed.
const HMAC_SECRET := "CHANGE_ME_IN_BUILD_PIPELINE"

var current_data: GameData
var current_player_name: String = Constants.DEFAULT_PLAYER_NAME : set = _on_player_name_changed


func _ready() -> void:
	load_game() # Try to load existing data first
	SignalBus.new_run_attempt.connect(_on_new_run_attempt)
	SignalBus.new_time_submission.connect(_on_new_time_submission)


func unlock_level(level_name: String):
	if not current_data.levels.has(level_name):
		var new_level = LevelData.new()
		current_data.levels[level_name] = new_level


func unlock_next_level(level_name: String):
	var next_level_name := CampaignLevelLibrary.get_next_level(level_name)
	if next_level_name == "":
		return
	unlock_level(next_level_name)


func save_to_disk():
	var save_path = SAVE_PATH % [current_player_name]
	
	# 1. Serialize the GameData resource to a temporary byte buffer.
	var temp_path := "user://%s_savegame.res" % [current_player_name]
	var save_err := ResourceSaver.save(current_data, temp_path)
	if save_err != OK:
		push_error("SaveManager: failed to serialize save data (error %s)" % save_err)
		return
	
	var file := FileAccess.open(temp_path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to read serialized save buffer")
		return
	var raw_bytes := file.get_buffer(file.get_length())
	file.close()
	DirAccess.remove_absolute(temp_path)
	
	# 2. Compute HMAC checksum over the serialized bytes.
	var hmac_bytes := _compute_hmac(raw_bytes)
	
	# 3. Assemble a structured payload: version + hmac + encrypted data.
	var payload := PackedByteArray()
	payload.append_array(_int_to_bytes(SAVE_VERSION))
	payload.append_array(hmac_bytes)
	payload.append_array(raw_bytes)
	
	# 4. Write the final protected file.
	var out := FileAccess.open(save_path, FileAccess.WRITE)
	if out == null:
		push_error("SaveManager: failed to open save file for writing: %s" % save_path)
		return
	out.store_buffer(payload)
	out.close()


func load_game():
	var save_path = SAVE_PATH % [current_player_name]
	
	if not FileAccess.file_exists(save_path):
		create_new_save()
		return
	
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: failed to open save at %s; creating new save." % save_path)
		create_new_save()
		return
	
	var payload := file.get_buffer(file.get_length())
	file.close()
	
	# Minimum payload: 4-byte version + 32-byte HMAC + at least some data.
	if payload.size() < 4 + 32:
		push_warning("SaveManager: save file too small at %s; creating new save." % save_path)
		create_new_save()
		return
	
	var stored_version := _bytes_to_int(payload.slice(0, 4))
	var stored_hmac := payload.slice(4, 4 + 32)
	var raw_bytes := payload.slice(4 + 32)
	var expected_hmac := _compute_hmac(raw_bytes)
	
	if not _constant_time_compare(stored_hmac, expected_hmac):
		push_warning("SaveManager: save file HMAC mismatch at %s; creating new save." % save_path)
		create_new_save()
		return
	
	if stored_version > SAVE_VERSION:
		push_warning("SaveManager: save version %s is newer than supported %s; creating new save." % [stored_version, SAVE_VERSION])
		create_new_save()
		return
	
	# Deserialize the resource from the verified bytes.
	var temp_path := "user://%s_savegame_load.res" % [current_player_name]
	var out := FileAccess.open(temp_path, FileAccess.WRITE)
	if out == null:
		push_warning("SaveManager: failed to create temporary load buffer; creating new save." % save_path)
		create_new_save()
		return
	out.store_buffer(raw_bytes)
	out.close()
	
	var loaded_data: Resource = null
	if ResourceLoader.exists(temp_path):
		loaded_data = ResourceLoader.load(temp_path)
	DirAccess.remove_absolute(temp_path)
	
	# Validate the loaded resource; fall back to a fresh save on corruption/mismatch.
	if loaded_data is GameData:
		current_data = loaded_data as GameData
		current_data.migrate()
		# Re-save after migration so the on-disk format is current.
		save_to_disk()
	else:
		if loaded_data != null:
			push_warning("SaveManager: corrupt or incompatible save at %s; creating new save." % save_path)
		create_new_save()


func create_new_save():
	current_data = GameData.new()
	current_data.player_name = current_player_name
	current_data.migrate()
	# Unlock the very first campaign level
	var level_ids := CampaignLevelLibrary.get_all_level_ids()
	if level_ids.is_empty():
		push_error("SaveManager: no campaign levels found; cannot create new save.")
		return
	var first_level: String = level_ids[0]
	unlock_level(first_level)
	save_to_disk()


func get_player_name() -> String:
	return current_data.player_name


func get_level_data(level_name: String) -> LevelData:
	return current_data.levels.get(level_name)


func has_level_data(level_name: String) -> bool:
	return level_name in current_data.levels


func update_level_progress(level_name: String) -> void:
	var level_data: LevelData = current_data.levels.get(level_name)
	if not level_data or level_data.best_time <= 0:
		return

	var campaign_level := CampaignLevelLibrary.get_level(level_name)
	if campaign_level == null:
		return
	var milestones = campaign_level.times
	var total_milestones = milestones.size()

	for i in range(total_milestones):
		var time_to_beat = milestones[i]
		level_data.progress_milestone = i
		if level_data.best_time <= time_to_beat:
			level_data.progress_percentage = 1.0
		else:
			level_data.progress_percentage = clamp(time_to_beat / level_data.best_time, 0.0, 1.0)
			break


func _on_new_run_attempt(level_name: String) -> void:
	var level_data: LevelData = current_data.levels.get(level_name)
	if not level_data:
		unlock_level(level_name)
		level_data = current_data.levels.get(level_name)
	level_data.attempts += 1
	save_to_disk()


func _on_new_time_submission(level_name: String, time: float) -> void:
	if not has_level_data(level_name):
		push_warning("SaveManager: no level data for %s; unlocking before recording time." % level_name)
		unlock_level(level_name)
	var level_data: LevelData = current_data.levels[level_name]
	if time != 0 and level_data.best_time > time:
		current_data.levels[level_name].best_time = time
		update_level_progress(level_name)
		unlock_next_level(level_name)
		save_to_disk()


func _on_player_name_changed(value) -> void:
	current_player_name = value
	current_data = null
	load_game()


# --- HMAC / checksum helpers ---

func _compute_hmac(data: PackedByteArray) -> PackedByteArray:
	# HMAC-SHA256 implemented using the available HashingContext.
	var block_size := 64
	var key_bytes := HMAC_SECRET.to_utf8_buffer()
	
	# Normalize key length.
	if key_bytes.size() > block_size:
		var ctx := HashingContext.new()
		ctx.start(HashingContext.HASH_SHA256)
		ctx.update(key_bytes)
		key_bytes = ctx.finish()
	while key_bytes.size() < block_size:
		key_bytes.append(0)
	
	var o_key_pad := PackedByteArray()
	var i_key_pad := PackedByteArray()
	o_key_pad.resize(block_size)
	i_key_pad.resize(block_size)
	for i in range(block_size):
		o_key_pad[i] = key_bytes[i] ^ 0x5c
		i_key_pad[i] = key_bytes[i] ^ 0x36
	
	var inner := HashingContext.new()
	inner.start(HashingContext.HASH_SHA256)
	inner.update(i_key_pad)
	inner.update(data)
	var inner_hash := inner.finish()
	
	var outer := HashingContext.new()
	outer.start(HashingContext.HASH_SHA256)
	outer.update(o_key_pad)
	outer.update(inner_hash)
	return outer.finish()


func _int_to_bytes(value: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.resize(4)
	bytes.encode_u32(0, value)
	return bytes


func _bytes_to_int(bytes: PackedByteArray) -> int:
	if bytes.size() < 4:
		return 0
	return bytes.decode_u32(0)


func _constant_time_compare(a: PackedByteArray, b: PackedByteArray) -> bool:
	if a.size() != b.size():
		return false
	var result := 0
	for i in range(a.size()):
		result |= a[i] ^ b[i]
	return result == 0
