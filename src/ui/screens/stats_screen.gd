extends MarginContainer

@onready var total_attempts_label = %TotalAttemptsLabel
@onready var total_time_label = %TotalTimeLabel
@onready var daily_attempts_label = %DailyAttemptsLabel
@onready var daily_time_label = %DailyTimeLabel
@onready var weekly_attempts_label = %WeeklyAttemptsLabel
@onready var weekly_time_label = %WeeklyTimeLabel
@onready var cosmetics_label = %CosmeticsLabel
@onready var back_button: Button = %BackButton


func _ready() -> void:
	_update_stats()
	back_button.grab_focus()
	TelemetrySystem.menu_opened("stats_screen")


func _update_stats() -> void:
	total_attempts_label.text = str(SaveManager.get_total_attempts())
	total_time_label.text = Utils.format_duration(SaveManager.get_total_time_played())
	daily_attempts_label.text = str(SaveManager.get_daily_attempts())
	daily_time_label.text = Utils.format_duration(SaveManager.get_daily_time_played())
	weekly_attempts_label.text = str(SaveManager.get_weekly_attempts())
	weekly_time_label.text = Utils.format_duration(SaveManager.get_weekly_time_played())
	var cosmetics := SaveManager.get_unlocked_cosmetics()
	cosmetics_label.text = ", ".join(cosmetics) if not cosmetics.is_empty() else "None"


func _on_back_button_pressed() -> void:
	SceneLoader.go_to("res://src/ui/screens/main_menu.tscn")
