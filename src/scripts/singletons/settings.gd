extends Node

## Settings
## Global user preferences: volume, fullscreen, input remap.
## Persisted independently from progress data via SettingsData.

const SETTINGS_PATH := "user://settings.res"
const SETTINGS_VERSION := 1
const SAVE_DEBOUNCE_SECONDS := 0.3

var _settings_data: SettingsData
var _save_timer: Timer
var _pending_save := false


func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = SAVE_DEBOUNCE_SECONDS
	_save_timer.timeout.connect(_flush_pending_save)
	add_child(_save_timer)
	load_settings()


var master_volume: float = 1.0 : set = set_master_volume
var music_volume: float = 1.0 : set = set_music_volume
var sfx_volume: float = 1.0 : set = set_sfx_volume
var fullscreen: bool = false : set = set_fullscreen


func load_settings() -> void:
	var loaded: Resource = null
	if ResourceLoader.exists(SETTINGS_PATH):
		loaded = ResourceLoader.load(SETTINGS_PATH)

	if loaded is SettingsData:
		_settings_data = loaded as SettingsData
		_settings_data.migrate()
	else:
		if loaded != null:
			push_warning("Settings: corrupt or incompatible settings file; creating fresh settings.")
		_settings_data = SettingsData.new()
		_settings_data.migrate()
		_save_settings_to_disk()

	_sync_from_data()
	_apply_settings()


func save_settings() -> void:
	_sync_to_data()
	_schedule_save()
	_apply_settings()


func _schedule_save() -> void:
	if _settings_data == null:
		return
	_pending_save = true
	if _save_timer == null:
		_save_settings_to_disk()
		return
	if not _save_timer.is_stopped():
		_save_timer.stop()
	_save_timer.start()


func _flush_pending_save() -> void:
	if _pending_save:
		_save_settings_to_disk()
		_pending_save = false


func _save_settings_to_disk() -> void:
	if _settings_data == null:
		return
	var err := ResourceSaver.save(_settings_data, SETTINGS_PATH)
	if err != OK:
		push_error("Settings: failed to save settings to %s (error %s)" % [SETTINGS_PATH, err])


func _sync_from_data() -> void:
	master_volume = _settings_data.master_volume
	music_volume = _settings_data.music_volume
	sfx_volume = _settings_data.sfx_volume
	fullscreen = _settings_data.fullscreen


func _sync_to_data() -> void:
	_settings_data.master_volume = master_volume
	_settings_data.music_volume = music_volume
	_settings_data.sfx_volume = sfx_volume
	_settings_data.fullscreen = fullscreen


func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	AudioManager.set_bus_volume("Master", master_volume)


func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	AudioManager.set_bus_volume("Music", music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	AudioManager.set_bus_volume("SFX", sfx_volume)


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _apply_settings() -> void:
	AudioManager.set_bus_volume("Master", master_volume)
	AudioManager.set_bus_volume("Music", music_volume)
	AudioManager.set_bus_volume("SFX", sfx_volume)
	set_fullscreen(fullscreen)
