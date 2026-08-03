extends Node

## Test: arcade time-bonus scoring.
## Verifies the continuous medal-band multiplier, pending-bonus banking,
## forfeit-on-death, and run-summary bonus totals.

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
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(6.0, bronze, silver, gold, config), 1.0):
		_push_fail("t >= bronze should be multiplier 1.0")
		return false
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(bronze, bronze, silver, gold, config), 1.0):
		_push_fail("t == bronze should be multiplier 1.0")
		return false
	var mid_bronze := ArcadeDirector.calculate_time_multiplier(5.0, bronze, silver, gold, config)
	if mid_bronze <= 1.0 or mid_bronze >= 1.5:
		_push_fail("between bronze/silver should be in (1.0, 1.5), got %f" % mid_bronze)
		return false
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(silver, bronze, silver, gold, config), 1.5):
		_push_fail("t == silver should be multiplier 1.5")
		return false
	var mid_silver := ArcadeDirector.calculate_time_multiplier(3.2, bronze, silver, gold, config)
	if mid_silver <= 1.5 or mid_silver >= 2.0:
		_push_fail("between silver/gold should be in (1.5, 2.0), got %f" % mid_silver)
		return false
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(gold, bronze, silver, gold, config), 2.0):
		_push_fail("t == gold should be multiplier 2.0")
		return false
	var sub_gold := ArcadeDirector.calculate_time_multiplier(1.0, bronze, silver, gold, config)
	if sub_gold <= 2.0 or sub_gold >= 3.0:
		_push_fail("t < gold should be in (2.0, 3.0), got %f" % sub_gold)
		return false
	if not is_equal_approx(ArcadeDirector.calculate_time_multiplier(0.0, bronze, silver, gold, config), 3.0):
		_push_fail("t == 0 should be multiplier 3.0")
		return false

	# --- Integration: banking, pending pool, forfeit on death ---
	ArcadeDirector.start_arcade_run()
	if GameSession.level_name != LEVEL_1_1:
		_push_fail("arcade run should start on %s" % LEVEL_1_1)
		return false
	if ArcadeDirector.get_pending_bonus() != 0:
		_push_fail("pending bonus should start at 0")
		return false

	ArcadeDirector.on_level_finished(5.0)
	var first_bonus := ArcadeDirector.get_pending_bonus()
	if first_bonus <= 0:
		_push_fail("clearing 1-1 in 5s should leave a pending bonus")
		return false
	var expected_first := roundi(config.level_clear_score * (mid_bronze - 1.0))
	if first_bonus != expected_first:
		_push_fail("expected first bonus %d, got %d" % [expected_first, first_bonus])
		return false

	var score_after_first := ArcadeDirector.score
	ArcadeDirector.on_level_finished(2.0)
	if ArcadeDirector.score != score_after_first + first_bonus + config.level_clear_score:
		_push_fail("second clear should bank the first bonus + base score")
		return false
	if ArcadeDirector.combo_streak != 1:
		_push_fail("combo streak should be 1 after banking")
		return false
	if ArcadeDirector.get_pending_bonus() <= 0:
		_push_fail("second clear should leave a new pending bonus")
		return false

	var score_before_death := ArcadeDirector.score
	ArcadeDirector.on_player_died()
	if ArcadeDirector.get_pending_bonus() != 0:
		_push_fail("death should forfeit the pending bonus")
		return false
	if ArcadeDirector.score != score_before_death:
		_push_fail("death must not bank the forfeited bonus")
		return false
	if ArcadeDirector.combo_streak != 0:
		_push_fail("death should reset the combo streak")
		return false

	# --- End-of-run banking via last level ---
	GameSession.level_name = LEVEL_1_17
	ArcadeDirector.on_level_finished(6.0)
	var pending_at_end := ArcadeDirector.get_pending_bonus()
	if pending_at_end <= 0:
		_push_fail("final clear should leave a pending bonus")
		return false
	if not ArcadeDirector.has_run_to_submit():
		_push_fail("final clear should end the run")
		return false

	var summary := ArcadeDirector.get_run_summary()
	if int(summary.get("bonus_total", 0)) <= 0:
		_push_fail("summary bonus_total should be positive")
		return false
	var bonuses: Array = summary.get("bonuses", [])
	var sum_check := 0
	for entry in bonuses:
		sum_check += int(entry.get("bonus", 0))
	if sum_check != int(summary.get("bonus_total", 0)):
		_push_fail("bonus_total should equal the sum of per-level bonuses")
		return false
	if int(summary.get("score", 0)) <= 0:
		_push_fail("summary score should be positive")
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
