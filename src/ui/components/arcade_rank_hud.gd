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

@onready var time_container: MarginContainer = %TimeContainer
@onready var band_label: Label = %BandLabel
@onready var medal_bar: Panel = %MedalBar
@onready var medal_bar_fill: ColorRect = %MedalBarFill
@onready var rank_card: Label = %RankCard
@onready var score_vbox: VBoxContainer = %ScoreVBox
@onready var score_label: Label = %ScoreLabel
@onready var multiplier_label: Label = %MultiplierLabel

var _rank_tween: Tween = null
var _multiplier_tween: Tween = null
var _band_tween: Tween = null
var _last_rendered_score: int = -1
var _current_level_id: String = ""
var _level_times: Array[float] = []
var _current_band: String = ""


func _ready() -> void:
	ArcadeDirector.level_rank_awarded.connect(_on_level_rank_awarded)
	ArcadeDirector.run_multiplier_changed.connect(_on_run_multiplier_changed)


func _exit_tree() -> void:
	if ArcadeDirector.level_rank_awarded.is_connected(_on_level_rank_awarded):
		ArcadeDirector.level_rank_awarded.disconnect(_on_level_rank_awarded)
	if ArcadeDirector.run_multiplier_changed.is_connected(_on_run_multiplier_changed):
		ArcadeDirector.run_multiplier_changed.disconnect(_on_run_multiplier_changed)


func _process(_delta: float) -> void:
	_update_medal_pace()
	if GameSession.game_mode != GameSession.GameModes.ARCADE:
		if score_vbox.visible:
			score_vbox.visible = false
		return
	score_vbox.visible = true
	var current_score := ArcadeDirector.score
	if current_score != _last_rendered_score:
		_last_rendered_score = current_score
		score_label.text = "SCORE %08d" % current_score


func reset() -> void:
	rank_card.visible = false
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


func _update_medal_pace() -> void:
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
	_update_medal_bar(time)
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


func _update_medal_bar(time: float) -> void:
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
	var width := medal_bar.size.x * fill
	medal_bar_fill.size.x = width
	if fill <= 0.001 and medal_bar_fill.visible:
		medal_bar_fill.visible = false
	elif fill > 0.001 and not medal_bar_fill.visible:
		medal_bar_fill.visible = true


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
