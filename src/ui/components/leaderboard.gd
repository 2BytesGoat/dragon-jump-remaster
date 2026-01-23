extends MarginContainer

@onready var leaderboard_entry_container = %EntryContainer
@onready var leaderboard_placeholder_label = %LeaderboardPlaceholderLabel

@onready var leaderboard_entry_scene = preload("res://src/ui/components/leaderboard_entry.tscn")


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
	
	for score_entry in results["scores"]["scores"]:
		var entry_object = leaderboard_entry_scene.instantiate()
		entry_object.player_name = score_entry["player_name"]
		entry_object.player_score = Utils.format_time(score_entry["score"])
		leaderboard_entry_container.add_child(entry_object)
	
	# TODO: interweave player between leaderboard entries
	leaderboard_placeholder_label.visible = false
	leaderboard_entry_container.visible = true
	print("RESULT: ", results)
