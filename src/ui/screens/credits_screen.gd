extends Control

## CreditsScreen
## Full-screen overlay showing a Star Wars-style rolling text crawl.
## Any key / mouse click closes it back to the main menu.

const CRAWL_SPEED := 40.0
const SCREEN_HEIGHT := 360.0

@onready var crawl_text: RichTextLabel = %CrawlText
@onready var hint_label: Label = %HintLabel
@onready var background: ColorRect = %Background

var _crawl_offset := 0.0


func _ready() -> void:
	background.gui_input.connect(_on_background_gui_input)
	reset_crawl()


func reset_crawl() -> void:
	_crawl_offset = 0.0
	crawl_text.position = Vector2(crawl_text.position.x, SCREEN_HEIGHT)


func _process(delta: float) -> void:
	if not visible:
		return
	_crawl_offset += delta * CRAWL_SPEED
	crawl_text.position.y = SCREEN_HEIGHT - _crawl_offset


func _unhandled_input(event: InputEvent) -> void:
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
	visible = false
