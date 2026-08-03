extends CanvasLayer

## ArcadeRankHud
## Neon White-style feedback for the arcade time-bonus system:
## - Rank card popup at level clear (GOLD x2.0 +1303)
## - Pending bonus readout under the timer ("+1303 READY")
## - Multiplier readout under the score; pops on clear, resets red to x1.00 on death.

const RANK_COLORS := {
	"": Color(1.0, 1.0, 1.0, 1.0),
	"BRONZE": Color(0.804, 0.502, 0.196, 1.0),
	"SILVER": Color(0.753, 0.753, 0.753, 1.0),
	"GOLD": Color(0.996, 0.843, 0.0, 1.0),
	"GOLD+": Color(0.996, 0.843, 0.0, 1.0),
}

@onready var rank_card: Label = %RankCard
@onready var combo_readout: Label = %ComboReadout
@onready var score_vbox: VBoxContainer = %ScoreVBox
@onready var score_label: Label = %ScoreLabel
@onready var multiplier_label: Label = %MultiplierLabel

var _rank_tween: Tween = null
var _multiplier_tween: Tween = null
var _last_rendered_score: int = -1


func _ready() -> void:
	ArcadeDirector.level_rank_awarded.connect(_on_level_rank_awarded)
	ArcadeDirector.pending_bonus_changed.connect(_on_pending_bonus_changed)
	ArcadeDirector.combo_lost.connect(_on_combo_lost)


func _exit_tree() -> void:
	if ArcadeDirector.level_rank_awarded.is_connected(_on_level_rank_awarded):
		ArcadeDirector.level_rank_awarded.disconnect(_on_level_rank_awarded)
	if ArcadeDirector.pending_bonus_changed.is_connected(_on_pending_bonus_changed):
		ArcadeDirector.pending_bonus_changed.disconnect(_on_pending_bonus_changed)
	if ArcadeDirector.combo_lost.is_connected(_on_combo_lost):
		ArcadeDirector.combo_lost.disconnect(_on_combo_lost)


func _process(_delta: float) -> void:
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
		combo_readout.text = "READY"
		combo_readout.visible = false
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


func _on_pending_bonus_changed(bonus: int) -> void:
	if bonus <= 0:
		combo_readout.text = "READY"
		combo_readout.visible = false
		return
	combo_readout.text = "+%d READY" % bonus
	combo_readout.visible = true


func _on_combo_lost(_streak_before: int, _lost_bonus: int) -> void:
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
	combo_readout.visible = false
