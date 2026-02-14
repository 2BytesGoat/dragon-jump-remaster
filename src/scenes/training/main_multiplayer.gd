extends Node

@onready var multiplayer_world_scene = preload("res://src/scenes/training/multiplayer_world.tscn")
@onready var ghost_scene = preload("res://src/scenes/player/ghost.tscn")

# TODO: use a for loop to go through all levels
@onready var worlds = $Worlds
@onready var ghosts = $PlayerMirrors
@onready var sync = $Synchronizer

var DEFAULT_LEVEL_NAME = "1-1"
var DEFAULT_NB_AGENTS = 100

var main_world = null
var player_mapping = {}


func _ready() -> void:
	var level_name = EnvironmentVariables.args.get("level", DEFAULT_LEVEL_NAME)
	var nb_agents = EnvironmentVariables.args.get("nb_agents", DEFAULT_NB_AGENTS)
	
	var level_code = Constants.LEVELS[level_name]["code"]
	for i in range(nb_agents):
		var player_name = "Player%s" % i
		var world = multiplayer_world_scene.instantiate()
		worlds.add_child(world)
		world.set_params(level_code, player_name, Player.CONTROLLERS.TRAINING)
		world.visible = false
		
		var ghost = ghost_scene.instantiate()
		ghosts.add_child(ghost)
		ghost.name = "Ghost%s" % i
		player_mapping[player_name] = ghost
	
	main_world = worlds.get_child(0)
	main_world.visible = true
	main_world.set_camera_enabled(true)
	
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
