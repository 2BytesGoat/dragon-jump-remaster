extends MarginContainer

@export var tag_screen: MarginContainer
@export var settings_menu: MarginContainer

@onready var level_select = "res://src/ui/menus/level_select.tscn"
@onready var stats_screen = "res://src/ui/menus/stats_screen.tscn"
@onready var game_main_scene = "res://main.tscn"
@onready var play_button: Button = $SubViewportContainer/SubViewport/HBoxContainer/MarginContainer/VBoxContainer2/Panel/VBoxContainer/PlayButton
@onready var stats_button: Button = $SubViewportContainer/SubViewport/HBoxContainer/MarginContainer/VBoxContainer2/Panel/VBoxContainer/StatsButton
@onready var sound_button: Button = $SubViewportContainer/SubViewport/HBoxContainer/MarginContainer/VBoxContainer2/Panel/VBoxContainer/SoundButton


func _ready() -> void:
	tag_screen.visible = false
	if settings_menu != null:
		settings_menu.visible = false
	if play_button != null:
		play_button.grab_focus()
	TelemetrySystem.menu_opened("main_menu")


func _on_sound_button_pressed() -> void:
	if settings_menu != null:
		settings_menu.visible = true
		var close_button := settings_menu.find_child("CloseButton", true, false)
		if close_button is Button:
			close_button.grab_focus()


func _on_settings_menu_closed() -> void:
	if settings_menu != null:
		settings_menu.visible = false
	if sound_button != null:
		sound_button.grab_focus()


func _on_play_button_pressed() -> void:
	ArcadeDirector.start_arcade_run()
	SceneLoader.go_to(game_main_scene)


func _on_practice_button_pressed() -> void:
	GameSession.set_game_mode(GameSession.GameModes.PRACTICE)
	SceneLoader.go_to(level_select)


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


func _on_stats_button_pressed() -> void:
	SceneLoader.go_to(stats_screen)
