class_name RunTimer
extends Node

## RunTimer
## Gameplay run clock owned by main.gd, independent of any UI scene.
## Tracks the active run (first jump -> finish), emits time_changed for
## display, and accumulates session play time for SaveManager retention.

const FLUSH_INTERVAL_SEC := 10.0

signal time_changed(total_time: float)

var total_time := 0.0
var race_paused := false
var race_started := false
var session_elapsed := 0.0
var _last_flush := 0.0


func _process(delta: float) -> void:
	if not(not race_paused and race_started):
		return

	total_time += delta
	time_changed.emit(total_time)

	session_elapsed += delta
	if session_elapsed - _last_flush >= FLUSH_INTERVAL_SEC:
		_flush_session_time()


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


func _flush_session_time() -> void:
	var since_last_flush := session_elapsed - _last_flush
	if since_last_flush <= 0.0:
		return
	_last_flush = session_elapsed
	SignalBus.play_time_elapsed.emit(since_last_flush)


func reset() -> void:
	total_time = 0.0
	race_started = false
	race_paused = false
	time_changed.emit(total_time)
	_flush_session_time()


func _on_player_run_started(_player: Player):
	race_started = true
	race_paused = false


func _on_player_run_restarted(_player: Player):
	_flush_session_time()
	reset()


func _on_player_run_finished(_player: Player) -> void:
	race_started = false
	race_paused = true
	_flush_session_time()


func _on_main_game_paused(is_paused: bool) -> void:
	race_paused = is_paused
