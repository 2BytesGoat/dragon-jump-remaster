extends MarginContainer

const MAX_SUPPORTED_ENTRIES = 9
@onready var leaderboard_entry_container = %EntryContainer
@onready var leaderboard_placeholder_label = %LeaderboardPlaceholderLabel
@onready var server_error_label = %ServerErrorLabel

@onready var leaderboard_entry_scene = preload("res://src/ui/widgets/leaderboard_entry.tscn")
@onready var leaderboard_others_scene = preload("res://src/ui/widgets/others_label.tscn")


func _ready() -> void:
	_show_placeholder("Leaderboard disabled in V1.0.")


func update_leaderboard(_level_name: String):
	_show_placeholder("Leaderboard disabled in V1.0.")


func _show_placeholder(text: String) -> void:
	leaderboard_placeholder_label.text = text
	leaderboard_entry_container.visible = false
	server_error_label.visible = false
	leaderboard_placeholder_label.visible = true


func _render_results(_results: Dictionary) -> void:
	pass
