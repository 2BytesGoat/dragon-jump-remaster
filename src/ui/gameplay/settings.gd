extends MarginContainer

## SettingsMenu
## Pop-up menu for adjusting Master, Music, and SFX volume levels.

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var crt_checkbox: CheckBox = %CRTCheckBox
@onready var scanlines_checkbox: CheckBox = %ScanlinesCheckBox
@onready var scanlines_label: Label = %ScanlinesLabel
signal close_me


func _ready() -> void:
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	crt_checkbox.button_pressed = Settings.crt_enabled
	scanlines_checkbox.button_pressed = Settings.scanlines_enabled
	_update_scanlines_state()


func _update_scanlines_state() -> void:
	var crt_on := crt_checkbox.button_pressed
	scanlines_checkbox.disabled = not crt_on
	scanlines_label.modulate.a = 1.0 if crt_on else 0.4


func _on_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value
	Settings.save_settings()


func _on_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.save_settings()


func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.save_settings()


func _on_crt_checkbox_toggled(button_pressed: bool) -> void:
	Settings.crt_enabled = button_pressed
	Settings.save_settings()
	_update_scanlines_state()


func _on_scanlines_checkbox_toggled(button_pressed: bool) -> void:
	Settings.scanlines_enabled = button_pressed
	Settings.save_settings()


func _on_close_button_pressed() -> void:
	close_me.emit()
