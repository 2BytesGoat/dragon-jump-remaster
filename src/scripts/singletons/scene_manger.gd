extends Node

@onready var particles_scene = preload("res://src/scenes/effects/background_particles.tscn")
var scene_data = {}


func _ready() -> void:
	#var particles = particles_scene.instantiate()
	#add_child(particles)
	#particles.position.x += get_viewport().size.x / 4
	pass


func go_to(scene_path: String, data: Dictionary = {}):
	scene_data = data
	get_tree().change_scene_to_file(scene_path) 
