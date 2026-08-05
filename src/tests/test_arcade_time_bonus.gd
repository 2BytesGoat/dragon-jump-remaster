extends Node

## Test: arcade time-bonus scoring.
## Verifies the continuous medal-band multiplier, score accumulation,
## multiplier reset on death, and run-summary correctness.

const LEVEL_1_1 := "1-1"
const LEVEL_1_17 := "1-17"

var _original_level_name: String = ""


func run() -> bool:
	_original_level_name = GameSession.level_name
	var config: ArcadeConfig = ArcadeDirector.config
	if config == null:
		_push_fail("ArcadeDirector.config not loaded")
		return false

	var bronze := 5.975
	var silver := 3.9435
	var gold := 2.868

	# --- Multiplier boundaries (continuous piecewise) ---
	# Config: bronze=0.5, silver=1.5, gold=2.0, max=3.0

	# t >= bronze -> bronze_multiplier (0.5)
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(6.0, bronze, silver, gold, config), 0.5):
		_push_fail("t >= bronze should be multiplier 0.5")
		return false
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(bronze, bronze, silver, gold, config), 0.5):
		_push_fail("t == bronze should be multiplier 0.5")
		return false

	# Between bronze and silver -> lerp(0.5, 1.5, ...)
	var mid_bronze := ArcadeDirector.calculate_time_multiplier(5.0, bronze, silver, gold, config)
	if mid_bronze <= 0.5 or mid_bronze >= 1.5:
		_push_fail("between bronze/silver should be in (0.5, 1.5), got %f" % mid_bronze)
		return false

	# t == silver -> silver_multiplier (1.5)
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(silver, bronze, silver, gold, config), 1.5):
		_push_fail("t == silver should be multiplier 1.5")
		return false

	# Between silver and gold -> lerp(1.5, 2.0, ...)
	var mid_silver := ArcadeDirector.calculate_time_multiplier(3.2, bronze, silver, gold, config)
	if mid_silver <= 1.5 or mid_silver >= 2.0:
		_push_fail("between silver/gold should be in (1.5, 2.0), got %f" % mid_silver)
		return false

	# t == gold -> gold_multiplier (2.0)
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(gold, bronze, silver, gold, config), 2.0):
		_push_fail("t == gold should be multiplier 2.0")
		return false

	# t < gold -> lerp(2.0, 3.0, ...)
	var sub_gold := ArcadeDirector.calculate_time_multiplier(1.0, bronze, silver, gold, config)
	if sub_gold <= 2.0 or sub_gold >= 3.0:
		_push_fail("t < gold should be in (2.0, 3.0), got %f" % sub_gold)
		return false

	# t == 0 -> max_multiplier (3.0)
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(0.0, bronze, silver, gold, config), 3.0):
		_push_fail("t == 0 should be multiplier 3.0")
		return false

	# --- Integration: score accumulation, multiplier streak, death reset ---
	ArcadeDirector.start_arcade_run()
	if GameSession.level_name != LEVEL_1_1:
		_push_fail("arcade run should start on %s" % LEVEL_1_1)
		return false
	if ArcadeDirector.score != 0:
		_push_fail("score should start at 0")
		return false
	if ArcadeDirector.run_multiplier != 1.0:
		_push_fail("run_multiplier should start at 1.0")
		return false

	# Clear 1-1 in 5.0s (between bronze and silver)
	ArcadeDirector.on_level_finished(5.0)
	var expected_bonus_1 := roundi(config.level_clear_score * mid_bronze * 1.0)
	if ArcadeDirector.score != expected_bonus_1:
		_push_fail("after 1-1 clear, expected score %d, got %d" % [expected_bonus_1, ArcadeDirector.score])
		return false
	if ArcadeDirector.run_multiplier != 2.0:
		_push_fail("after first clear, run_multiplier should be 2.0, got %f" % ArcadeDirector.run_multiplier)
		return false

	# Death resets the multiplier
	var score_before_death := ArcadeDirector.score
	var lives_before := ArcadeDirector.lives
	ArcadeDirector.on_player_died()
	if ArcadeDirector.run_multiplier != 1.0:
		_push_fail("death should reset run_multiplier to 1.0")
		return false
	if ArcadeDirector.score != score_before_death:
		_push_fail("death must not change score")
		return false
	if ArcadeDirector.lives != lives_before - 1:
		_push_fail("death should decrement lives")
		return false

	# --- End-of-run: finish last level ---
	GameSession.level_name = LEVEL_1_17
	ArcadeDirector.on_level_finished(6.0)
	if not ArcadeDirector.has_run_to_submit():
		_push_fail("final clear should end the run")
		return false

	var summary := ArcadeDirector.get_run_summary()
	if int(summary.get("score", 0)) <= 0:
		_push_fail("summary score should be positive")
		return false
	if int(summary.get("levels_reached", 0)) < 2:
		_push_fail("summary levels_reached should be at least 2")
		return false
	if float(summary.get("best_streak", 0.0)) < 2.0:
		_push_fail("best_streak should be at least 2.0")
		return false

	var bonuses: Array = summary.get("bonuses", [])
	var sum_check := 0
	for entry in bonuses:
		sum_check += int(entry.get("bonus", 0))
	if sum_check != int(summary.get("bonus_total", 0)):
		_push_fail("bonus_total should equal the sum of per-level bonuses")
		return false

	_restore()
	return true


func _push_fail(message: String) -> void:
	push_error("ARCADE TIME BONUS TEST FAIL: %s" % message)


func _restore() -> void:
	GameSession.level_name = _original_level_name
	ArcadeDirector.start_arcade_run()


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("ARCADE TIME BONUS TEST: %s" % ("PASS" if passed else "FAIL"))
		get_tree().quit(0 if passed else 1)
