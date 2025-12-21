extends Node

var next_scene_data = {}

func go_to(scene_path: String, data: Dictionary = {}):
	next_scene_data = data
	get_tree().change_scene_to_file(scene_path) 
