extends Node

# TODO: use a for loop to go through all levels
@onready var worlds = $Worlds

var level_name = "1-14"


func _ready() -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	for i in range(worlds.get_child_count()):
		var world: MultiplayerWorld = worlds.get_child(i)
		var enable_camera = i == 0
		world.set_params(level_code, Player.CONTROLLERS.PLAYER_ONE, enable_camera)
	
	#SignalBus.player_started_run.connect(_on_player_started_run)
	#SignalBus.player_finished_run.connect(_on_player_finished_run)
