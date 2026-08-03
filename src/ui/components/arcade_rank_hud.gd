extends CanvasLayer

## ArcadeRankHud
## Neon White-style feedback for the arcade time-bonus system:
## - Rank card popup at level clear (GOLD x2.0 +1303)
## - Pending bonus readout under the timer ("+1303 READY")
## - Red "COMBO LOST -1303" flash when a pending bonus is forfeited by death.

const RANK_COLORS := {
	"": Color(1.0, 1.0, 1.0, 1.0),
	"BRONZE": Color(0.804, 0.502, 0.196, 1.0),
	"SILVER": Color(0.753, 0.753, 0.753, 1.0),
	"GOLD": Color(0.996, 0.843, 0.0, 1.0),
	"GOLD+": Color(0.996, 0.843, 0.0, 1.0),
}

@onready var rank_card: Label = %RankCard
@onready var combo_readout: Label = %ComboReadout
@onready var combo_lost_label: Label = %ComboLostLabel

var _rank_tween: Tween = null
var _lost_tween: Tween = null


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


func reset() -> void:
	_kill_tweens()
	rank_card.visible = false
	combo_lost_label.visible = false
	combo_readout.visible = false


func _on_level_rank_awarded(_level_id: String, rank: String, multiplier: float, bonus: int) -> void:
	_kill_tweens()
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


func _on_pending_bonus_changed(bonus: int) -> void:
	if bonus <= 0:
		combo_readout.text = "READY"
		combo_readout.visible = false
		return
	combo_readout.text = "+%d READY" % bonus
	combo_readout.visible = true


func _on_combo_lost(_streak_before: int, lost_bonus: int) -> void:
	if _lost_tween != null and _lost_tween.is_valid():
		_lost_tween.kill()
	combo_lost_label.text = "COMBO LOST -%d" % lost_bonus
	combo_lost_label.modulate.a = 1.0
	combo_lost_label.visible = true
	combo_readout.visible = false
	_lost_tween = create_tween()
	_lost_tween.tween_interval(1.1)
	_lost_tween.tween_property(combo_lost_label, "modulate:a", 0.0, 0.4)
	_lost_tween.tween_callback(func() -> void: combo_lost_label.visible = false)


func _kill_tweens() -> void:
	if _rank_tween != null and _rank_tween.is_valid():
		_rank_tween.kill()
	_rank_tween = null
	if _lost_tween != null and _lost_tween.is_valid():
		_lost_tween.kill()
	_lost_tween = null
