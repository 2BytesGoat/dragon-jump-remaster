extends MarginContainer

## SettingsMenu
## Pop-up menu for adjusting Master, Music, and SFX volume levels.

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var crt_checkbox: CheckBox = %CRTCheckBox
@onready var close_button: Button = %CloseButton
signal close_me


func _ready() -> void:
	master_slider.value = Settings.master_volume
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume
	crt_checkbox.button_pressed = Settings.crt_enabled
	_setup_hover_focus()


func _setup_hover_focus() -> void:
	for control: Control in [master_slider, music_slider, sfx_slider, crt_checkbox]:
		control.mouse_entered.connect(control.grab_focus)
		control.mouse_exited.connect(control.release_focus)
		control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


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
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_me.emit()
	elif get_viewport().gui_get_focus_owner() == null:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			get_viewport().set_input_as_handled()
			master_slider.grab_focus()
