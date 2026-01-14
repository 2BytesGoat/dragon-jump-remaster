extends MarginContainer

@onready var level_select = "src/ui/menus/level_select.tscn"


func _on_play_button_pressed() -> void:
	SceneManger.go_to(level_select)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
