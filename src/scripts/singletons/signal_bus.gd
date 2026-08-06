extends Node

## Cross-scene signals only.
## Player lifecycle signals (started/restarted/finished) now live on Player.

@warning_ignore("unused_signal")
signal new_run_attempt(level_name: String)
@warning_ignore("unused_signal")
signal new_time_submission(level_name: String, time: float)
@warning_ignore("unused_signal")
signal play_time_elapsed(seconds: float)
