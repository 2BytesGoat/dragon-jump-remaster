class_name ArcadeRankHud
extends CanvasLayer

## ArcadeRankHud
## Neon White-style feedback for the arcade score system:
## - Rank card popup at level clear (GOLD x2.00 +2000)
## - Streak multiplier readout under the score; pops on clear, resets red to x1.00 on death.
## - Level timer with live medal-pace tint: starts GOLD, downgrades through
##   SILVER/BRONZE as time crosses each threshold.

const MEDAL_TAGS := {
	"GOLD+": "GOLD+",
	"GOLD": "GOLD",
	"SILVER": "SILVER",
	"BRONZE": "BRONZE",
	"": "NO BONUS",
}

const MEDAL_INDEX := {
	"BRONZE": 0,
	"SILVER": 1,
	"GOLD": 2,
	"GOLD+": 2,
}


func _rank_color(rank: String) -> Color:
	if rank == "" or not MEDAL_INDEX.has(rank):
		return Color.WHITE
	return Constants.MEDAL_CONFIG.medal_colors[MEDAL_INDEX[rank]]

const STREAK_LOST_COLOR := Color(0.9, 0.2, 0.2)

const MEDAL_BAR_PULSE_THRESHOLD := 0.5
const MEDAL_BAR_HEARTBEAT_INTERVAL := 0.5
const MEDAL_BAR_HEARTBEAT_MIN_INTERVAL := 0.12
const LIFE_ICON_SIZE := 12.0
const LIFE_ICON_LOST_ALPHA := 0.25

@export var multiplier_pop_delay: float = 0.3
@export var bar_pulse_scale_x: float = 1.03
@export var bar_pulse_scale_y: float = 1.15

var run_timer: RunTimer = null
@onready var lives_box: HBoxContainer = %LivesBox
@onready var band_label: Label = %BandLabel
@onready var medal_bar: TextureProgressBar = %MedalBar
@onready var clear_sfx: AudioStreamPlayer = %ClearSFX
@onready var gold_sfx: AudioStreamPlayer = %GoldSFX
@onready var death_sfx: AudioStreamPlayer = %DeathSFX
@onready var score_vbox: VBoxContainer = %ScoreVBox
@onready var score_label: Label = %ScoreLabel
@onready var multiplier_label: Label = %MultiplierLabel

var _life_icons: Array[TextureRect] = []
var _multiplier_tween: Tween = null
var _band_tween: Tween = null
var _bar_pulse_tween: Tween = null
var _score_tween: Tween = null
var _reset_tween: Tween = null
var _multiplier_pop_timer: SceneTreeTimer = null
var _last_rendered_score: int = -1
var _current_level_id: String = ""
var _level_times: Array[float] = []
var _current_band: String = ""
var _medal_fill: float = 1.0
var _heartbeat_elapsed: float = 0.0
var _heartbeat_crossed: bool = false
var _flash_timer: SceneTreeTimer = null
var _base_medal_bar_scale: Vector2 = Vector2.ONE

## World position the level-clear popup should spawn above. Set by main.gd
## right before ArcadeDirector.on_level_finished() emits level_rank_awarded
## (that emit is synchronous, so this is always up to date when consumed).
var pending_popup_world_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_medal_bar_scale = medal_bar.scale
	medal_bar.pivot_offset = medal_bar.size / 2.0
	_build_life_icons()
	_reset_medal_bar_visuals()
	ArcadeDirector.level_rank_awarded.connect(_on_level_rank_awarded)
	ArcadeDirector.run_multiplier_changed.connect(_on_run_multiplier_changed)
	ArcadeDirector.lives_changed.connect(_on_lives_changed)


func _exit_tree() -> void:
	if ArcadeDirector.level_rank_awarded.is_connected(_on_level_rank_awarded):
		ArcadeDirector.level_rank_awarded.disconnect(_on_level_rank_awarded)
	if ArcadeDirector.run_multiplier_changed.is_connected(_on_run_multiplier_changed):
		ArcadeDirector.run_multiplier_changed.disconnect(_on_run_multiplier_changed)
	if ArcadeDirector.lives_changed.is_connected(_on_lives_changed):
		ArcadeDirector.lives_changed.disconnect(_on_lives_changed)


func _build_life_icons() -> void:
	for child in lives_box.get_children():
		child.queue_free()
	_life_icons = []
	var max_lives := ArcadeDirector.config.max_lives if ArcadeDirector.config != null else 3
	for i in range(max_lives):
		var icon := TextureRect.new()
		icon.texture = preload("res://icon.png")
		icon.custom_minimum_size = Vector2(LIFE_ICON_SIZE, LIFE_ICON_SIZE)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.modulate.a = LIFE_ICON_LOST_ALPHA
		lives_box.add_child(icon)
		_life_icons.append(icon)
	_refresh_lives(ArcadeDirector.lives)


func _on_lives_changed(lives: int) -> void:
	_refresh_lives(lives)


func _refresh_lives(lives: int) -> void:
	for i in range(_life_icons.size()):
		_life_icons[i].modulate.a = 1.0 if i < lives else LIFE_ICON_LOST_ALPHA


func _process(delta: float) -> void:
	_update_medal_pace(delta)
	if GameSession.game_mode != GameSession.GameModes.ARCADE:
		if score_vbox.visible:
			score_vbox.visible = false
		if lives_box.visible:
			lives_box.visible = false
		return
	score_vbox.visible = true
	lives_box.visible = true
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
	_refresh_lives(ArcadeDirector.lives)
	_last_rendered_score = ArcadeDirector.score
	multiplier_label.remove_theme_color_override("font_color")
	score_label.text = "SCORE %08d" % ArcadeDirector.score


func reset_medal_bar() -> void:
	_reset_medal_bar_visuals()


func _on_level_rank_awarded(_level_id: String, rank: String, multiplier: float, bonus: int) -> void:
	BonusPopup.spawn(self, "+%d" % bonus, _rank_color(rank), pending_popup_world_position)
	_schedule_multiplier_pop(multiplier, rank)
	# _play_clear_sfx(rank)  # SFX disabled for now — see game_juice_plan.md


func _schedule_multiplier_pop(multiplier: float, rank: String) -> void:
	_multiplier_pop_timer = get_tree().create_timer(multiplier_pop_delay)
	_multiplier_pop_timer.timeout.connect(func() -> void:
		if is_inside_tree():
			_show_multiplier_pop(multiplier, rank)
	)


func _show_multiplier_pop(_multiplier: float, rank: String) -> void:
	if _multiplier_tween != null and _multiplier_tween.is_valid():
		_multiplier_tween.kill()
	multiplier_label.text = "x%.2f" % ArcadeDirector.run_multiplier
	multiplier_label.add_theme_color_override("font_color", _rank_color(rank))
	multiplier_label.modulate.a = 1.0
	multiplier_label.scale = Vector2(0.4, 0.4)
	_multiplier_tween = create_tween()
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.15, 1.15), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_multiplier_tween.tween_property(multiplier_label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_SINE)


func _play_clear_sfx(rank: String) -> void:
	if rank == "GOLD" or rank == "GOLD+":
		gold_sfx.play()
	else:
		clear_sfx.play()


func _on_run_multiplier_changed(multiplier: float) -> void:
	if multiplier == 1.0:
		_play_multiplier_death_reset()
		return
	#if _multiplier_tween != null and _multiplier_tween.is_valid():
	#	_multiplier_tween.kill()
	#multiplier_label.text = "x%.2f" % multiplier
	#multiplier_label.remove_theme_color_override("font_color")
	#multiplier_label.modulate.a = 1.0
	#multiplier_label.scale = Vector2.ONE


func _play_multiplier_death_reset() -> void:
	if _multiplier_tween != null and _multiplier_tween.is_valid():
		_multiplier_tween.kill()
	# death_sfx.play()  # SFX disabled for now — see game_juice_plan.md
	multiplier_label.add_theme_color_override("font_color", STREAK_LOST_COLOR)
	multiplier_label.modulate.a = 1.0
	multiplier_label.scale = Vector2.ONE
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
		multiplier_label.modulate.a = 1.0
		multiplier_label.scale = Vector2.ONE
		multiplier_label.remove_theme_color_override("font_color")
	)


func _update_medal_pace(delta: float) -> void:
	if run_timer == null:
		return
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
	var time = run_timer.total_time
	_update_medal_bar(time, delta)
	if not run_timer.race_started:
		return
	var band := _band_for_time(time)
	if band == _current_band:
		return
	var downgraded := _current_band != "" and _rank_weight(band) < _rank_weight(_current_band)
	_current_band = band
	band_label.text = MEDAL_TAGS.get(band, "---")
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
	var band := _band_for_time(run_timer.total_time)
	var color: Color = _rank_color(band)
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
	medal_bar.tint_progress = color.lightened(0.35)
	_flash_timer = get_tree().create_timer(0.12)
	_flash_timer.timeout.connect(_on_flash_timer_timeout.bind(color))
	_pulse_bar_scale()


func _on_flash_timer_timeout(color: Color) -> void:
	if _medal_fill > 0.0:
		medal_bar.tint_progress = color


func _pulse_bar_scale() -> void:
	if _bar_pulse_tween != null and _bar_pulse_tween.is_valid():
		_bar_pulse_tween.kill()
	medal_bar.scale = _base_medal_bar_scale
	_bar_pulse_tween = create_tween()
	_bar_pulse_tween.tween_property(medal_bar, "scale", _base_medal_bar_scale * Vector2(bar_pulse_scale_x, bar_pulse_scale_y), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_bar_pulse_tween.tween_property(medal_bar, "scale", _base_medal_bar_scale, 0.15).set_trans(Tween.TRANS_SINE)


func _update_medal_bar(time: float, delta: float) -> void:
	if not run_timer.race_started:
		_stop_medal_bar_pulse()
		return
	var thresholds := _get_medal_thresholds()
	var bronze: float = thresholds[0]
	var silver: float = thresholds[1]
	var gold: float = thresholds[2]
	var fill: float
	var color: Color
	if time >= bronze:
		fill = 0.0
		color = _rank_color("")
	elif time >= silver:
		fill = clampf((bronze - time) / maxf(bronze - silver, 0.0001), 0.0, 1.0)
		color = _rank_color("BRONZE")
	elif time >= gold:
		fill = clampf((silver - time) / maxf(silver - gold, 0.0001), 0.0, 1.0)
		color = _rank_color("SILVER")
	else:
		fill = clampf((gold - time) / maxf(gold, 0.0001), 0.0, 1.0)
		color = _rank_color("GOLD")
	medal_bar.tint_progress = color
	_medal_fill = fill
	medal_bar.value = fill * medal_bar.max_value
	if fill <= 0.001:
		return
	_pulse_medal_bar(MEDAL_BAR_PULSE_THRESHOLD, delta)


func _stop_medal_bar_pulse() -> void:
	if _bar_pulse_tween != null and _bar_pulse_tween.is_valid():
		_bar_pulse_tween.kill()
	medal_bar.scale = _base_medal_bar_scale
	_heartbeat_elapsed = 0.0
	_heartbeat_crossed = false


func _reset_medal_bar_visuals() -> void:
	_stop_medal_bar_pulse()
	if _band_tween != null and _band_tween.is_valid():
		_band_tween.kill()
	if _reset_tween != null and _reset_tween.is_valid():
		_reset_tween.kill()
	_medal_fill = 1.0
	_current_band = "GOLD"
	band_label.text = "GOLD"
	band_label.modulate.a = 1.0
	medal_bar.visible = true
	_reset_tween = create_tween()
	_reset_tween.set_parallel(true)
	_reset_tween.tween_property(medal_bar, "value", medal_bar.max_value, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_reset_tween.tween_property(medal_bar, "tint_progress", _rank_color("GOLD"), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	band_label.scale = Vector2(0.5, 0.5)
	_band_tween = create_tween()
	_band_tween.tween_property(band_label, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_band_tween.tween_property(band_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)


func _band_for_time(time: float) -> String:
	var thresholds := _get_medal_thresholds()
	var bronze: float = thresholds[0]
	var silver: float = thresholds[1]
	var gold: float = thresholds[2]
	if time >= bronze:
		return ""
	if time >= silver:
		return "BRONZE"
	if time >= gold:
		return "SILVER"
	return "GOLD"


func _get_medal_thresholds() -> Array[float]:
	var times := _level_times
	if times.is_empty():
		return [INF, INF, INF]
	var bronze: float = times[0]
	var gold: float = times[-1]
	var silver: float = times[1] if times.size() >= 3 else gold
	return [bronze, silver, gold]


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
