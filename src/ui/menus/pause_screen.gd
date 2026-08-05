extends MarginContainer


@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var pause_panel: Panel = $Panel
@onready var settings_menu: MarginContainer = $SettingsMenu


func set_pause_active(value: bool) -> void:
	if value:
		pause_panel.visible = true
		if settings_menu != null:
			settings_menu.visible = false
		if resume_button != null:
			resume_button.grab_focus()
	else:
		if pause_panel != null:
			pause_panel.visible = false
		if settings_menu != null:
			settings_menu.visible = false


func _on_settings_button_pressed() -> void:
	if pause_panel != null:
		pause_panel.visible = false
	if settings_menu != null:
		settings_menu.visible = true
		var close_button := settings_menu.find_child("CloseButton", true, false)
		if close_button is Button:
			close_button.grab_focus()


func _on_settings_menu_closed() -> void:
	if settings_menu != null:
		settings_menu.visible = false
	if pause_panel != null:
		pause_panel.visible = true
	if settings_button != null:
		settings_button.grab_focus()


func close_settings_if_open() -> bool:
	if settings_menu != null and settings_menu.visible:
		_on_settings_menu_closed()
		return true
	return false
