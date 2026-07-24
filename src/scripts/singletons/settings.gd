extends Node

## Settings
## Global user preferences: volume, fullscreen, input remap.
## Persisted through SaveManager.

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var fullscreen: bool = false


func _ready() -> void:
	load_settings()


func load_settings() -> void:
	var data = SaveManager.current_data.settings if SaveManager.current_data else {}
	master_volume = data.get("master_volume", 1.0)
	music_volume = data.get("music_volume", 1.0)
	sfx_volume = data.get("sfx_volume", 1.0)
	fullscreen = data.get("fullscreen", false)
	_apply_settings()


func save_settings() -> void:
	if SaveManager.current_data:
		SaveManager.current_data.settings = {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"fullscreen": fullscreen
		}
		SaveManager.save_to_disk()
	_apply_settings()


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