extends MarginContainer


@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var pause_panel: Panel = $Panel
@onready var settings_menu: MarginContainer = $SettingsMenu


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	if not visible:
		return
	if settings_menu != null and settings_menu.visible:
		var close_button := settings_menu.find_child("CloseButton", true, false)
		if close_button is Button:
			close_button.grab_focus()
	elif resume_button != null:
		resume_button.grab_focus()


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


func close_settings_if_open() -> void:
	if settings_menu != null and settings_menu.visible:
		_on_settings_menu_closed()
