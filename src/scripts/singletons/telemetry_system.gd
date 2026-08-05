extends Node

## TelemetrySystem
## Lightweight analytics abstraction layer.
## Events are logged locally in debug builds. Backends (SilentWolf/GameAnalytics)
## can be swapped in later without touching game code.

enum EventName {
	LEVEL_STARTED,
	LEVEL_FINISHED,
	RUN_RESTARTED,
	POWERUP_USED,
	DEATH,
	MENU_OPENED,
}

const EVENT_KEYS: Array[String] = [
	"level_started",
	"level_finished",
	"run_restarted",
	"powerup_used",
	"death",
	"menu_opened",
]

## Set to true in production once a backend is integrated.
@export var enable_remote: bool = false

var _session_id: String
var _session_start: int


func _ready() -> void:
	_session_id = _generate_session_id()
	_session_start = Time.get_ticks_msec()
	_log_debug("session_start", {"session_id": _session_id})


func track(event: EventName, payload: Dictionary = {}) -> void:
	var event_key := EVENT_KEYS[event]
	var enriched := payload.duplicate()
	enriched["session_id"] = _session_id
	enriched["session_ms"] = Time.get_ticks_msec() - _session_start
	_log_debug(event_key, enriched)
	if enable_remote:
		_send_remote(event_key, enriched)


func level_started(level_name: String) -> void:
	track(EventName.LEVEL_STARTED, {"level_name": level_name})


func level_finished(level_name: String, time: float) -> void:
	track(EventName.LEVEL_FINISHED, {"level_name": level_name, "time": time})


func run_restarted(level_name: String) -> void:
	track(EventName.RUN_RESTARTED, {"level_name": level_name})


func powerup_used(powerup_name: String) -> void:
	track(EventName.POWERUP_USED, {"powerup_name": powerup_name})


func death(reason: String, level_name: String = "", powerups_lost: int = 0) -> void:
	track(EventName.DEATH, {"reason": reason, "level_name": level_name, "powerups_lost": powerups_lost})


func menu_opened(menu_name: String) -> void:
	track(EventName.MENU_OPENED, {"menu_name": menu_name})


func _log_debug(event_key: String, payload: Dictionary) -> void:
	if OS.is_debug_build():
		print("[Telemetry] %s: %s" % [event_key, payload])


func _send_remote(_event_key: String, _payload: Dictionary) -> void:
	# Remote backend integration point. Keep no-op until a provider is wired.
	pass


func _generate_session_id() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return "%x%x" % [Time.get_ticks_msec(), rng.randi()]
