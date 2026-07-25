extends MarginContainer

@onready var time_label = $TimeLabel

var total_time := 0.0
var delta_time := 0.0
var race_paused := false
var race_started := false


func _ready() -> void:
	reset()


func track_player(player: Player) -> void:
	_disconnect_player_signals(player)
	player.run_started.connect(_on_player_run_started)
	player.run_restarted.connect(_on_player_run_restarted)
	player.run_finished.connect(_on_player_run_finished)


func _disconnect_player_signals(player: Player) -> void:
	if player.run_started.is_connected(_on_player_run_started):
		player.run_started.disconnect(_on_player_run_started)
	if player.run_restarted.is_connected(_on_player_run_restarted):
		player.run_restarted.disconnect(_on_player_run_restarted)
	if player.run_finished.is_connected(_on_player_run_finished):
		player.run_finished.disconnect(_on_player_run_finished)


func _process(delta: float) -> void:
	if not(not race_paused and race_started):
		return
	
	total_time += delta
	time_label.text = Utils.format_time(total_time)


func reset() -> void:
	total_time = 0.0
	delta_time = 0.0
	race_started = false
	race_paused = false
	time_label.text = "00:00.00"


func _on_player_run_started(_player: Player):
	race_started = true
	race_paused = false


func _on_player_run_restarted(_player: Player):
	reset()


func _on_player_run_finished(_player: Player) -> void:
	race_started = false
	race_paused = true


func _on_main_game_paused(is_paused: bool) -> void:
	race_paused = is_paused
