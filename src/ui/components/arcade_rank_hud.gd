extends CanvasLayer

## ArcadeRankHud
## Neon White-style feedback for the arcade score system:
## - Rank card popup at level clear (GOLD x2.00 +2000)
## - Streak multiplier readout under the score; pops on clear, resets red to x1.00 on death.
## - Level timer with live medal-pace tint: starts GOLD, downgrades through
##   SILVER/BRONZE as time crosses each threshold.

const RANK_COLORS := {
	"": Color(1.0, 1.0, 1.0, 1.0),
	"BRONZE": Color(0.804, 0.502, 0.196, 1.0),
	"SILVER": Color(0.753, 0.753, 0.753, 1.0),
	"GOLD": Color(0.996, 0.843, 0.0, 1.0),
	"GOLD+": Color(0.996, 0.843, 0.0, 1.0),
}

const MEDAL_TAGS := {
	"GOLD+": "GOLD+",
	"GOLD": "GOLD",
	"SILVER": "SILVER",
	"BRONZE": "BRONZE",
	"": "---",
}

const MEDAL_BAR_PULSE_THRESHOLD := 0.5
const MEDAL_BAR_HEARTBEAT_INTERVAL := 0.5
const MEDAL_BAR_HEARTBEAT_MIN_INTERVAL := 0.12

@onready var time_container: MarginContainer = %TimeContainer
@onready var band_label: Label = %BandLabel
@onready var medal_bar: Panel = %MedalBar
@onready var medal_bar_fill: ColorRect = %MedalBarFill
@onready var rank_card: Label = %RankCard
@onready var bonus_popup: Label = %BonusPopup
@onready var clear_flash: ColorRect = %ClearFlash
@onready var clear_sfx: AudioStreamPlayer = %ClearSFX
@onready var gold_sfx: AudioStreamPlayer = %GoldSFX
@onready var death_sfx: AudioStreamPlayer = %DeathSFX
@onready var score_vbox: VBoxContainer = %ScoreVBox
@onready var score_label: Label = %ScoreLabel
@onready var multiplier_label: Label = %MultiplierLabel

var _rank_tween: Tween = null
var _multiplier_tween: Tween = null
var _band_tween: Tween = null
var _bar_pulse_tween: Tween = null
var _score_tween: Tween = null
var _popup_tween: Tween = null
var _flash_tween: Tween = null
var _last_rendered_score: int = -1
var _current_level_id: String = ""
var _level_times: Array[float] = []
var _current_band: String = ""
var _medal_fill: float = 1.0
var _heartbeat_elapsed: float = 0.0
var _heartbeat_crossed: bool = false


func _ready() -> void:
	ArcadeDirector.level_rank_awarded.connect(_on_level_rank_awarded)
	ArcadeDirector.run_multiplier_changed.connect(_on_run_multiplier_changed)


func _exit_tree() -> void:
	if ArcadeDirector.level_rank_awarded.is_connected(_on_level_rank_awarded):
		ArcadeDirector.level_rank_awarded.disconnect(_on_level_rank_awarded)
	if ArcadeDirector.run_multiplier_changed.is_connected(_on_run_multiplier_changed):
		ArcadeDirector.run_multiplier_changed.disconnect(_on_run_multiplier_changed)


func _process(delta: float) -> void:
	_update_medal_pace(delta)
	if GameSession.game_mode != GameSession.GameModes.ARCADE:
		if score_vbox.visible:
			score_vbox.visible = false
		return
	score_vbox.visible = true
	var current_score := ArcadeDirector.score
	if current_score != _last_rendered_score:
		_last_rendered_score = current_score
		_roll_score(current_score)


func _roll_score(target: int) -> void:
	if _score_tween != null and _score_tween.is_valid():
		_score_tween.kill()
	var start := _score_from_label()
	_score_tween = create_tween()
	_score_tween.tween_method(_set_score_text, start, target, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _score_from_label() -> int:
	var text := score_label.text.trim_prefix("SCORE ")
	return int(text) if text.is_valid_int() else 0


func _set_score_text(value: int) -> void:
	score_label.text = "SCORE %08d" % value


func reset() -> void:
	if _rank_tween != null and _rank_tween.is_valid():
		_rank_tween.kill()
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	rank_card.visible = false
	bonus_popup.visible = false
	clear_flash.visible = false
	_last_rendered_score = ArcadeDirector.score
	score_label.text = "SCORE %08d" % ArcadeDirector.score


func _on_level_rank_awarded(_level_id: String, rank: String, multiplier: float, bonus: int) -> void:
	if bonus <= 0:
		return
	var multiplier_text := "x%.2f" % multiplier
	rank_card.text = "%s %s  +%d" % [rank, multiplier_text, bonus]
	rank_card.add_theme_color_override("font_color", RANK_COLORS.get(rank, Color.WHITE))
	rank_card.scale = Vector2(0.4, 0.4)
	rank_card.modulate.a = 0.0
	rank_card.visible = true
	_rank_tween = create_tween().set_parallel(true)
	_rank_tween.tween_property(rank_card, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_rank_tween.tween_property(rank_card, "modulate:a", 1.0, 0.1)
	_rank_tween.set_parallel(false)
	_rank_tween.tween_interval(0.9)
	_rank_tween.tween_property(rank_card, "modulate:a", 0.0, 0.4)
	_rank_tween.tween_callback(func() -> void: rank_card.visible = false)
	_show_multiplier_pop(multiplier, rank)
	_show_bonus_popup(bonus, rank)
	_play_clear_flash(rank)
	# _play_clear_sfx(rank)  # SFX disabled for now — see game_juice_plan.md


func _show_multiplier_pop(multiplier: float, rank: String) -> void:
	if _multiplier_tween != null and _multiplier_tween.is_valid():
		_multiplier_tween.kill()
	multiplier_label.text = "x%.2f" % multiplier
	multiplier_label.add_theme_color_override("font_color", RANK_COLORS.get(rank, Color.WHITE))
	multiplier_label.modulate.a = 1.0
	multiplier_label.scale = Vector2(0.4, 0.4)
	_multiplier_tween = create_tween()
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.3, 1.3), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE)


func _show_bonus_popup(bonus: int, rank: String) -> void:
	if _popup_tween != null and _popup_tween.is_valid():
		_popup_tween.kill()
	bonus_popup.text = "+%d" % bonus
	bonus_popup.add_theme_color_override("font_color", RANK_COLORS.get(rank, Color.WHITE))
	bonus_popup.modulate.a = 0.0
	bonus_popup.visible = true
	var start_pos := bonus_popup.position
	_popup_tween = create_tween().set_parallel(true)
	_popup_tween.tween_property(bonus_popup, "modulate:a", 1.0, 0.12)
	_popup_tween.tween_property(bonus_popup, "position", start_pos + Vector2(0, -30), 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_popup_tween.set_parallel(false)
	_popup_tween.tween_interval(0.35)
	_popup_tween.tween_property(bonus_popup, "modulate:a", 0.0, 0.35)
	_popup_tween.tween_callback(func() -> void: bonus_popup.visible = false)


func _play_clear_flash(rank: String) -> void:
	if _flash_tween != null and _flash_tween.is_valid():
		_flash_tween.kill()
	var color: Color = RANK_COLORS.get(rank, Color.WHITE)
	clear_flash.color = Color(color.r, color.g, color.b, 0.0)
	clear_flash.visible = true
	_flash_tween = create_tween()
	_flash_tween.tween_property(clear_flash, "color:a", 0.22, 0.08)
	_flash_tween.tween_property(clear_flash, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flash_tween.tween_callback(func() -> void: clear_flash.visible = false)


func _play_clear_sfx(rank: String) -> void:
	if rank == "GOLD" or rank == "GOLD+":
		gold_sfx.play()
	else:
		clear_sfx.play()


func _on_run_multiplier_changed(multiplier: float) -> void:
	if multiplier == 1.0:
		_play_multiplier_death_reset()
		return
	if _multiplier_tween != null and _multiplier_tween.is_valid():
		_multiplier_tween.kill()
	multiplier_label.text = "x%.2f" % multiplier
	multiplier_label.modulate.a = 1.0
	multiplier_label.scale = Vector2.ONE
	multiplier_label.add_theme_color_override("font_color", RANK_COLORS.get("GOLD", Color.WHITE))


func _play_multiplier_death_reset() -> void:
	if _multiplier_tween != null and _multiplier_tween.is_valid():
		_multiplier_tween.kill()
	# death_sfx.play()  # SFX disabled for now — see game_juice_plan.md
	multiplier_label.modulate.a = 1.0
	multiplier_label.scale = Vector2.ONE
	multiplier_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
	_multiplier_tween = create_tween()
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.4, 1.4), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_multiplier_tween.tween_callback(func() -> void:
		multiplier_label.text = "x1.00"
		multiplier_label.scale = Vector2(1.4, 1.4)
	)
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_multiplier_tween.tween_interval(0.4)
	_multiplier_tween.tween_property(multiplier_label, "modulate:a", 0.25, 0.4)
	_multiplier_tween.tween_callback(func() -> void:
		multiplier_label.add_theme_color_override("font_color", Color.WHITE)
		multiplier_label.modulate.a = 1.0
		multiplier_label.scale = Vector2.ONE
	)


func _update_medal_pace(delta: float) -> void:
	var level_id := GameSession.level_name
	if level_id != _current_level_id:
		_current_level_id = level_id
		_level_times = []
		var level_data := CampaignLevelLibrary.get_level(level_id)
		if level_data != null:
			_level_times = level_data.times.duplicate()
		_current_band = ""
	if _level_times.is_empty():
		medal_bar.visible = false
		return
	medal_bar.visible = true
	var time = time_container.total_time
	_update_medal_bar(time, delta)
	var band := _band_for_time(time)
	if band == _current_band:
		return
	var downgraded := _current_band != "" and _rank_weight(band) < _rank_weight(_current_band)
	_current_band = band
	band_label.text = MEDAL_TAGS.get(band, "---")
	band_label.add_theme_color_override("font_color", RANK_COLORS.get(band, Color.WHITE))
	if downgraded:
		band_label.scale = Vector2(0.5, 0.5)
		band_label.modulate.a = 1.0
		if _band_tween != null and _band_tween.is_valid():
			_band_tween.kill()
		_band_tween = create_tween()
		_band_tween.tween_property(band_label, "scale", Vector2(1.4, 1.4), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_band_tween.tween_property(band_label, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)


func _pulse_medal_bar(pulse_from_percent: float, delta: float) -> bool:
	if _medal_fill > pulse_from_percent:
		_heartbeat_elapsed = 0.0
		_heartbeat_crossed = false
		return false
	var band := _band_for_time(time_container.total_time)
	var color: Color = RANK_COLORS.get(band, Color.WHITE)
	if not _heartbeat_crossed:
		_heartbeat_crossed = true
		_heartbeat_elapsed = 0.0
		_flash_fill(color)
		return true
	_heartbeat_elapsed += delta
	var interval := _heartbeat_interval()
	if _heartbeat_elapsed < interval:
		return false
	_heartbeat_elapsed = 0.0
	_flash_fill(color)
	return true


func _heartbeat_interval() -> float:
	var t := clampf(_medal_fill / MEDAL_BAR_PULSE_THRESHOLD, 0.0, 1.0)
	return lerpf(MEDAL_BAR_HEARTBEAT_MIN_INTERVAL, MEDAL_BAR_HEARTBEAT_INTERVAL, t)


func _flash_fill(color: Color) -> void:
	medal_bar_fill.color = color.lightened(0.35)
	var timer := get_tree().create_timer(0.12)
	timer.timeout.connect(func() -> void:
		if _medal_fill > 0.0:
			medal_bar_fill.color = color
	)
	_pulse_bar_scale()


func _pulse_bar_scale() -> void:
	if _bar_pulse_tween != null and _bar_pulse_tween.is_valid():
		_bar_pulse_tween.kill()
	medal_bar.pivot_offset = medal_bar.size / 2.0
	medal_bar.scale = Vector2.ONE
	_bar_pulse_tween = create_tween()
	_bar_pulse_tween.tween_property(medal_bar, "scale", Vector2(1.06, 1.6), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_bar_pulse_tween.tween_property(medal_bar, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE)


func _update_medal_bar(time: float, delta: float) -> void:
	var times := _level_times
	var bronze: float = times[0]
	var silver: float = times[1] if times.size() >= 3 else times[0]
	var gold: float = times[-1]
	var fill: float
	var color: Color
	if time >= bronze:
		fill = 0.0
		color = RANK_COLORS.get("", Color.WHITE)
	elif time >= silver:
		fill = clampf((bronze - time) / maxf(bronze - silver, 0.0001), 0.0, 1.0)
		color = RANK_COLORS["BRONZE"]
	elif time >= gold:
		fill = clampf((silver - time) / maxf(silver - gold, 0.0001), 0.0, 1.0)
		color = RANK_COLORS["SILVER"]
	else:
		fill = clampf((gold - time) / maxf(gold, 0.0001), 0.0, 1.0)
		color = RANK_COLORS["GOLD"]
	medal_bar_fill.color = color
	_medal_fill = fill
	var width := medal_bar.size.x * fill
	medal_bar_fill.size.x = width
	if fill <= 0.001 and medal_bar_fill.visible:
		medal_bar_fill.visible = false
	elif fill > 0.001 and not medal_bar_fill.visible:
		medal_bar_fill.visible = true
	if not medal_bar_fill.visible:
		return
	_pulse_medal_bar(MEDAL_BAR_PULSE_THRESHOLD, delta)


func _band_for_time(time: float) -> String:
	var times := _level_times
	var bronze: float = times[0]
	var silver: float = times[1] if times.size() >= 3 else times[0]
	var gold: float = times[-1]
	if time >= bronze:
		return ""
	if time >= silver:
		return "BRONZE"
	if time >= gold:
		return "SILVER"
	return "GOLD"


func _rank_weight(band: String) -> int:
	match band:
		"GOLD+":
			return 5
		"GOLD":
			return 4
		"SILVER":
			return 3
		"BRONZE":
			return 2
		_:
			return 1
