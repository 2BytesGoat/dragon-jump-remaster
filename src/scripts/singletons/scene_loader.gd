extends Node
var scene_data = {}


func go_to(scene_path: String, data: Dictionary = {}):
	scene_data = data
	# Defer the scene change so any pending input event is fully processed
	# before the old viewport/SubViewport leaves the scene tree.
	call_deferred("_change_scene", scene_path)


func _change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
