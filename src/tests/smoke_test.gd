extends Node

## Smoke Test
## Verifies boot, core autoloads, level parsing, and save/load without player input.

var _level_scene := preload("res://src/scenes/level/level.tscn")


func _ready() -> void:
	_run_checks()
	await get_tree().process_frame
	get_tree().quit()


func _run_checks() -> void:
	_check_autoload("SaveManager", SaveManager)
	_check_autoload("SceneLoader", SceneLoader)
	_check_autoload("AudioManager", AudioManager)
	_check_autoload("Settings", Settings)
	_check_autoload("GameSession", GameSession)
	
	_check_constants()
	_check_resources()
	_check_level_load()
	_check_save_round_trip()
	
	print("SMOKE TEST PASS")


func _check_autoload(name: String, node: Node) -> void:
	if node == null:
		push_error("Missing autoload: %s" % name)
		get_tree().quit(1)


func _check_constants() -> void:
	assert(Constants.DEFAULT_PLAYER_NAME != "", "Constants helper must be reachable")
	assert(Constants.PHYSICS_PARAMS != null, "PhysicsParams resource must be loaded")
	assert(Constants.MEDAL_CONFIG != null, "MedalConfig resource must be loaded")
	assert(Constants.POWERUP_PALETTE != null, "PowerupPalette resource must be loaded")
	assert(Constants.AUDIO_BUS_CONFIG != null, "AudioBusConfig resource must be loaded")


func _check_resources() -> void:
	assert(CampaignLevelLibrary.get_level("1-1") != null, "Campaign level 1-1 must exist")


func _check_level_load() -> void:
	var level_data := CampaignLevelLibrary.get_level("1-1")
	var level: Level = _level_scene.instantiate()
	add_child(level)
	level.load_level(level_data)
	assert(level.get_level_size_cell().x > 0, "Level width must be positive")
	assert(level.player_start_position != Vector2.ZERO, "Player start must be set")
	level.queue_free()


func _check_save_round_trip() -> void:
	var original_name = SaveManager.current_player_name
	SaveManager.current_player_name = "SMOKE"
	SaveManager.create_new_save()
	assert(SaveManager.has_level_data("1-1"), "First level should be unlocked")
	SaveManager.unlock_level("1-2")
	SaveManager.save_to_disk()
	SaveManager.load_game()
	assert(SaveManager.has_level_data("1-2"), "Unlocked level should persist")
	SaveManager.current_player_name = original_name
	SaveManager.load_game()
	# Give queued nodes a frame to be freed before shutdown to reduce exit leaks.
	await get_tree().process_frame
