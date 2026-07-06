extends MarginContainer

@onready var time_label = $TimeLabel

var total_time := 0.0
var delta_time := 0.0
var race_paused := false
var race_started := false


func _ready() -> void:
	SignalBus.player_started_run.connect(_on_player_started_run)
	SignalBus.player_restarted_run.connect(_on_player_restarted_run)
	SignalBus.player_finished_run.connect(_on_player_finished_run)
	
	reset()


func _process(delta: float) -> void:
	if not(not race_paused and race_started):
		return
	
	total_time += delta
	time_label.text = Utils.format_time(total_time)


func reset() -> void:
	total_time = 0.0
	delta_time = 0.0
	time_label.text = "00:00.00"


func _on_player_started_run(_player: Player):
	race_started = true
	race_paused = false


func _on_player_restarted_run(_player: Player):
	reset()


func _on_player_finished_run(_player: Player) -> void:
	race_started = false
	race_paused = true


func _on_main_game_paused(is_paused: bool) -> void:
	race_paused = is_paused
