extends MarginContainer

@onready var tag_screen = $TagScreen
@onready var level_select = "src/ui/menus/level_select.tscn"
@onready var main_multiplayer = "res://src/scenes/training/main_multiplayer.tscn"


func _ready() -> void:
	if "port" in EnvironmentVariables.args:
		SceneManger.go_to(main_multiplayer)
	tag_screen.visible = false


func _on_play_button_pressed() -> void:
	if SaveManager.get_player_name() == Constants.DEFAULT_PLAYER_NAME:
		tag_screen.visible = true
	else:
		SceneManger.go_to(level_select)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_confirm_button_pressed() -> void:
	var input_player_tag = tag_screen.player_tag
	if not Utils.is_allowed_player_name(input_player_tag):
		tag_screen.player_tag = ""
		tag_screen.placeholder = "Only Letters Allowed"
		return
	
	SaveManager.current_player_name = tag_screen.player_tag
	SceneManger.go_to(level_select)


func _on_skip_button_pressed() -> void:
	SceneManger.go_to(level_select)
