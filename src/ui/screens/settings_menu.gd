extends MarginContainer

## SettingsMenu
## Pop-up menu for adjusting Master, Music, and SFX volume levels.

@onready var master_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MasterVolumeRow/MasterSlider
@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MusicVolumeRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/MarginContainer/VBoxContainer/SFXVolumeRow/SFXSlider


func _ready() -> void:
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume


func _on_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.save_settings()


func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.save_settings()


func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.save_settings()


func _on_close_button_pressed() -> void:
	visible = false
