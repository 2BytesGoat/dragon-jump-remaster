extends MarginContainer

## CreditsScreen
## Full-screen overlay showing a Star Wars-style rolling text crawl.
## Any key / mouse click closes it back to the main menu.

signal closed

const CRAWL_SPEED := 40.0
const SCREEN_HEIGHT := 360.0
const FADE_DURATION := 0.5
const END_HOLD_DURATION := 1.0

@onready var crawl_text: RichTextLabel = %CrawlText
@onready var hint_label: Label = %HintLabel
@onready var background: ColorRect = %Background

var _crawl_offset := 0.0
var _crawl_finished := false


func _ready() -> void:
	background.gui_input.connect(_on_background_gui_input)
	reset_crawl()


func reset_crawl() -> void:
	_crawl_offset = 0.0
	_crawl_finished = false
	crawl_text.position = Vector2(crawl_text.position.x, SCREEN_HEIGHT)


func _process(delta: float) -> void:
	if not visible:
		return
	_crawl_offset += delta * CRAWL_SPEED
	crawl_text.position.y = SCREEN_HEIGHT - _crawl_offset
	if not _crawl_finished and crawl_text.position.y + crawl_text.size.y <= 0.0:
		_crawl_finished = true
		var tween := create_tween()
		tween.tween_interval(END_HOLD_DURATION)
		tween.tween_callback(close)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		get_viewport().set_input_as_handled()
		close()
	elif event is InputEventJoypadButton and event.pressed:
		get_viewport().set_input_as_handled()
		close()


func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func close() -> void:
	if not visible:
		return
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_fade_out_finished)


func _on_fade_out_finished() -> void:
	visible = false
	modulate.a = 1.0
	closed.emit()
