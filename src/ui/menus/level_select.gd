extends MarginContainer

@onready var level_button_container = %LevelButtonContainer
@onready var level_node = %Level

@onready var level_button_scene = preload("res://src/ui/menus/level_button.tscn")
@onready var single_player_scene = "res://main.tscn"


func _ready() -> void:
	var cnt = 0
	for level_name in Constants.LEVELS:
		var button: Button = level_button_scene.instantiate()
		button.name = level_name
		button.text = str(level_name)
		level_button_container.add_child(button)
		
		button.focus_entered.connect(_on_level_button_hovered.bind(level_name))
		button.pressed.connect(_on_level_button_clicked.bind(level_name))
		
		if cnt == 0:
			button.grab_focus()
		cnt += 1


func _on_level_button_hovered(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]
	level_node.update_level(level_code)


func _on_level_button_clicked(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]
	SceneManger.go_to(single_player_scene, {"level_code": level_code})
