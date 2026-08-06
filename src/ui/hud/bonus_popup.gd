class_name BonusPopup
extends Label

## Reusable one-shot score/bonus popup. Spawn a fresh instance per bonus via
## spawn(); it animates (pop in -> drift up -> fade out) above a world position
## then frees itself, so concurrent bonuses stack cleanly.
##
## Renders in the gameplay HUD CanvasLayer (same SubViewport as the player), so
## world positions map to screen coordinates via get_canvas_transform().

const BONUS_POPUP_SCENE := preload("res://src/ui/hud/bonus_popup.tscn")
const CONFIG := preload("res://resources/bonus_popup_config.tres")

const HUD_GROUP := "GameplayHud"

## Vertical gap between the player's head and the popup's bottom edge.
const ABOVE_HEAD_OFFSET := 32.0


## Instantiates a popup, parents it, and plays it above `world_position`.
## The instance frees itself when its animation finishes.
static func spawn(parent: Node, text: String, color: Color, world_position: Vector2) -> BonusPopup:
	var popup: BonusPopup = BONUS_POPUP_SCENE.instantiate()
	parent.add_child(popup)
	popup.play(text, color, world_position)
	return popup


## Finds the CanvasLayer that hosts gameplay HUD elements, so world-side
## callers (secrets, pickups) can spawn popups without a hard reference.
static func find_hud() -> CanvasLayer:
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return tree.get_first_node_in_group(HUD_GROUP)
	return null


func play(text_value: String, color: Color, world_position: Vector2) -> void:
	self.text = text_value
	self_modulate = color
	# size is 0 until layout runs, so force it from the text before centering.
	reset_size()
	var screen_position: Vector2 = get_viewport().get_canvas_transform() * (world_position + CONFIG.position_offset)
	position = screen_position - Vector2(size.x / 2.0, size.y + ABOVE_HEAD_OFFSET)

	modulate.a = 0.0
	scale = Vector2(0.4, 0.4)

	var drift_time := maxf(0.1, CONFIG.lifetime - CONFIG.pop_in_time - CONFIG.fade_out_time)
	var target_y := position.y - CONFIG.drift

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, CONFIG.pop_in_time)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), CONFIG.pop_in_time * 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "position:y", target_y, drift_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, CONFIG.fade_out_time)
	tween.tween_callback(queue_free)
