extends Resource
class_name GameData

## In-memory progress schema.
## Serialized to an encrypted binary file with an HMAC checksum.

const SAVE_VERSION := 1

@export var save_version: int = SAVE_VERSION
@export var player_name = Constants.DEFAULT_PLAYER_NAME
@export var levels = {}

## Retention counters. Stored as simple ints so they survive across sessions.
@export var total_attempts: int = 0
@export var total_time_played_seconds: float = 0.0
@export var daily_attempts: int = 0
@export var daily_time_played_seconds: float = 0.0
@export var weekly_attempts: int = 0
@export var weekly_time_played_seconds: float = 0.0
@export var last_played_date: String = ""
@export var last_played_week: String = ""

## Unlocked cosmetic ids (hats/skins).
@export var unlocked_cosmetics: Array[String] = []


func migrate() -> void:
	if save_version < SAVE_VERSION:
		save_version = SAVE_VERSION
	# Future migrations go here.


## Returns the current UTC date as an ISO-8601 string (YYYY-MM-DD).
func get_today_date() -> String:
	return Time.get_date_string_from_system(true)


## Returns the current ISO-8601 week string (YYYY-WNN).
func get_current_week() -> String:
	var dict := Time.get_datetime_dict_from_system(true)
	# Godot does not expose week number directly; approximate via epoch day.
	var epoch_day := int(Time.get_unix_time_from_system()) / 86400
	var week := (epoch_day + 3) / 7
	return "%04d-W%02d" % [dict.year, week % 52]


## Reset daily/weekly counters when the stored date/week no longer matches today.
func refresh_periodic_counters() -> void:
	var today := get_today_date()
	var week := get_current_week()
	if last_played_date != today:
		daily_attempts = 0
		daily_time_played_seconds = 0.0
		last_played_date = today
	if last_played_week != week:
		weekly_attempts = 0
		weekly_time_played_seconds = 0.0
		last_played_week = week

