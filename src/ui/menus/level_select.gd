extends MarginContainer

@onready var level_button_container = %LevelButtonContainer
@onready var level_node = %Level
@onready var selected_level_label = %SelectedLevelLabel
@onready var speed_slider = %SpeedSlider

@onready var level_button_scene = preload("res://src/ui/menus/level_button.tscn")
@export var single_player_scene: PackedScene
@export var main_menu_scene: PackedScene

var selected_level_name = ""


func _ready() -> void:
	var cnt = 0
	
	for child in level_button_container.get_children():
		level_button_container.remove_child(child)
		child.queue_free()
	
	for i in len(Constants.LEVELS):
		var level_name = Constants.LEVELS.keys()[i]
		var button: Button = level_button_scene.instantiate()
		button.name = level_name
		level_button_container.add_child(button)
		button.button_label = "%03d - %s" % [i, Constants.LEVELS[level_name]["name"]]
		
		button.pressed.connect(_on_level_button_clicked.bind(level_name))
		
		if cnt == 0:
			_on_level_button_clicked(level_name)
			button.grab_focus()
		cnt += 1


func _on_level_button_hovered(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	level_node.update_level(level_code)


func _on_level_button_clicked(level_name: String) -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	level_node.update_level(level_code)
	selected_level_name = level_name
	
	var i = Constants.LEVELS.keys().find(level_name)
	selected_level_label.text = "%03d - %s" % [i, Constants.LEVELS[level_name]["name"]]


func _on_start_button_pressed() -> void:
	if not selected_level_name:
		return
	var speed_modifier = speed_slider.value + 0.5
	
	var next_level_name = Constants.get_next_level(selected_level_name)
	var next_level_code = ""
	if next_level_name:
		next_level_code = Constants.LEVELS[next_level_name]["code"]
	
	SceneManger.go_to(single_player_scene.resource_path, {"level_name": selected_level_name, "speed_modifier": speed_modifier})


func _on_back_button_pressed() -> void:
	SceneManger.go_to(main_menu_scene.resource_path)
