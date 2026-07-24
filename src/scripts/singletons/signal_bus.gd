extends Node

## Cross-scene signals only.
## Player lifecycle signals (started/restarted/finished) now live on Player.

signal new_run_attempt(level_name: String)
signal new_time_submission(level_name: String, time: float)
