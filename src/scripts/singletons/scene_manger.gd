extends Node
var scene_data = {}


func go_to(scene_path: String, data: Dictionary = {}):
	scene_data = data
	get_tree().change_scene_to_file(scene_path) 
