extends Resource
class_name SettingsData

## Persisted user preferences.
## Saved independently from progress data so sliders/config changes are cheap.

const SETTINGS_VERSION := 1

@export var version: int = SETTINGS_VERSION
@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var fullscreen: bool = false


func migrate() -> void:
	if version < SETTINGS_VERSION:
		version = SETTINGS_VERSION
