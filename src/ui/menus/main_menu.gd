extends Control

@export var tag_screen: MarginContainer
@export var settings_menu: MarginContainer
@export var credits_screen: Control

@onready var level_select = "res://src/ui/menus/level_select.tscn"
@onready var custom_levels_menu = "res://src/ui/screens/custom_levels_menu.tscn"
@onready var game_main_scene = "res://main.tscn"
@onready var play_button: Button = $SubViewportContainer/SubViewport/MenuSelectionScreen/VBoxContainer/VBoxContainer2/Panel/VBoxContainer/PlayButton
@onready var sound_button: Button = $SubViewportContainer/SubViewport/MenuSelectionScreen/VBoxContainer/VBoxContainer2/Panel/VBoxContainer/Footer/SettingsButton


func _ready() -> void:
	tag_screen.visible = false
	if settings_menu != null:
		settings_menu.visible = false
	if credits_screen != null:
		credits_screen.visible = false
	if play_button != null:
		play_button.grab_focus()
	TelemetrySystem.menu_opened("main_menu")


func _on_sound_button_pressed() -> void:
	if settings_menu != null:
		settings_menu.visible = true
		var close_button := settings_menu.find_child("CloseButton", true, false)
		if close_button is Button:
			close_button.grab_focus()


func _on_credits_button_pressed() -> void:
	if credits_screen != null:
		credits_screen.visible = true
		if credits_screen.has_method("reset_crawl"):
			credits_screen.reset_crawl()


func _on_settings_menu_closed() -> void:
	if settings_menu != null:
		settings_menu.visible = false
	if sound_button != null:
		sound_button.grab_focus()


func _on_discord_button_pressed() -> void:
	OS.shell_open(Constants.DISCORD_URL)


func _on_website_button_pressed() -> void:
	OS.shell_open(Constants.WEBSITE_URL)


func _on_play_button_pressed() -> void:
	ArcadeDirector.start_arcade_run()
	SceneLoader.go_to(game_main_scene)


func _on_practice_button_pressed() -> void:
	GameSession.set_game_mode(GameSession.GameModes.PRACTICE)
	GameSession.custom_level_code = ""
	SceneLoader.go_to(level_select)


func _on_create_button_pressed() -> void:
	SceneLoader.go_to(custom_levels_menu)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_confirm_button_pressed() -> void:
	var input_player_tag = tag_screen.player_tag
	if not Utils.is_allowed_player_name(input_player_tag):
		tag_screen.player_tag = ""
		tag_screen.placeholder = "Only Letters Allowed"
		return
	
	ArcadeDirector.submit_tag(input_player_tag)
	SceneLoader.go_to(level_select)


func _on_skip_button_pressed() -> void:
	SceneLoader.go_to(level_select)
