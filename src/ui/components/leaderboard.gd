extends MarginContainer

const MAX_SUPPORTED_ENTRIES = 9
@onready var leaderboard_entry_container = %EntryContainer
@onready var leaderboard_placeholder_label = %LeaderboardPlaceholderLabel

@onready var leaderboard_entry_scene = preload("res://src/ui/components/leaderboard_entry.tscn")
@onready var leaderboard_others_scene = preload("res://src/ui/menus/others_label.tscn")


func _ready() -> void:
	SignalBus.leaderboard_scores_updated.connect(update_leaderboard)


func update_leaderboard(level_name: String):
	leaderboard_entry_container.visible = false
	leaderboard_placeholder_label.visible = true
	
	var results = LeaderboardManager.get_local_leaderboard(level_name)
	if not results:
		LeaderboardManager.update_local_leaderboard(level_name)
		return
	
	if results.get("status") == "updating":
		return
	
	for child in leaderboard_entry_container.get_children():
		leaderboard_entry_container.remove_child(child)
		child.queue_free()
	
	var maded_to_leaderboard = []
	var player_name = SaveManager.get_player_name()
	for entry_name in results["scores"]:
		var entry_object = leaderboard_entry_scene.instantiate()
		entry_object.player_name = entry_name if entry_name != player_name else "> %s" % player_name
		entry_object.player_score = Utils.format_time(results["scores"][entry_name])
		leaderboard_entry_container.add_child(entry_object)
		maded_to_leaderboard.append(entry_name)
		if leaderboard_entry_container.get_child_count() >= MAX_SUPPORTED_ENTRIES:
			break
	
	var player_time = results["player_time"]
	if player_name != Constants.DEFAULT_PLAYER_NAME and player_time != INF and player_name not in maded_to_leaderboard:
		while leaderboard_entry_container.get_child_count() > MAX_SUPPORTED_ENTRIES - 2:
			var last_entry = leaderboard_entry_container.get_child(leaderboard_entry_container.get_child_count() - 1)
			leaderboard_entry_container.remove_child(last_entry)
			last_entry.queue_free()
		
		var others_label = leaderboard_others_scene.instantiate()
		leaderboard_entry_container.add_child(others_label)
		var entry_object = leaderboard_entry_scene.instantiate()
		entry_object.player_name = player_name
		entry_object.player_score = Utils.format_time(results["player_time"])
		leaderboard_entry_container.add_child(entry_object)
	
	leaderboard_placeholder_label.visible = false
	leaderboard_entry_container.visible = true
