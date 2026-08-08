extends MarginContainer

## SettingsMenu
## Pop-up menu for adjusting Master, Music, and SFX volume levels.

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var crt_checkbox: CheckBox = %CRTCheckBox
signal close_me
  

func _ready() -> void:
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	crt_checkbox.button_pressed = Settings.crt_enabled


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


func _on_close_button_pressed() -> void:
	close_me.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_me.emit()
