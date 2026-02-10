extends Node

# TODO: use a for loop to go through all levels
@onready var worlds = $Worlds
@onready var sync = $Synchronizer

var level_name = "1-14"
var main_world = null
@onready var player_mapping = {
	"Player0": $PlayerMirrors/Ghost,
	"Player1": $PlayerMirrors/Ghost2,
}


func _ready() -> void:
	var level_code = Constants.LEVELS[level_name]["code"]
	for i in range(worlds.get_child_count()):
		var world: MultiplayerWorld = worlds.get_child(i)
		var player_name = "Player%s" % i
		world.set_params(level_code, player_name, Player.CONTROLLERS.TRAINING)
	
	main_world = worlds.get_child(0)
	main_world.set_camera_enabled(true)
	main_world.track_node(player_mapping["Player0"])
	
	sync.initialize()
	#SignalBus.player_started_run.connect(_on_player_started_run)
	#SignalBus.player_finished_run.connect(_on_player_finished_run)


func _process(_delta: float) -> void:
	var player_node = null
	var viewport = main_world.viewport
	
	for agent_node in sync.agents_training:
		player_node = agent_node.player
		var sprite_node = player_mapping[player_node.name]
		var info = agent_node.get_info()
		
		var canvas_transform = viewport.get_canvas_transform()
		var screen_pos = canvas_transform * info.get("global_position")
		sprite_node.update(screen_pos, info.get("facing_direction"), info.get("state"))
		
	main_world.track_node(player_node)
