extends MarginContainer

@onready var level_button_container = %LevelButtonContainer
@onready var level_node = %Level

@onready var level_button_scene = preload("res://src/ui/menus/level_button.tscn")


func _ready() -> void:
	for level_name in Constants.LEVELS:
		var button: Button = level_button_scene.instantiate()
		button.name = level_name
		button.text = str(level_name)
		level_button_container.add_child(button)
		button.focus_entered.connect(_on_level_button_hovered.bind(level_name))


func _on_level_button_hovered(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]
	level_node.update_level(level_code)
