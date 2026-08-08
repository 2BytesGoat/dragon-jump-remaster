extends Control

## MainScreen
## Root of the main menu: hosts the MainMenu, the PracticeMenu, and the CreditsScreen overlay,
## fading between screens on request and back to the menu on close.

const SCREEN_FADE_IN_DURATION := 0.25
const MUSIC_FADE_IN_DURATION := 0.5
const MUSIC_VOLUME_DB := -15.0

const GROOVY_BOOTY := preload("res://assets/music/Groovy booty.ogg")

@onready var main_menu: MarginContainer = %MainMenu
@onready var practice_menu: MarginContainer = %PracticeMenu
@onready var credits_screen: MarginContainer = %CreditsScreen

var _transitioning := false


func _ready() -> void:
	main_menu.credits_requested.connect(_on_credits_requested)
	main_menu.practice_requested.connect(_on_practice_requested)
	credits_screen.closed.connect(_on_credits_closed)
	practice_menu.closed.connect(_on_practice_closed)
	main_menu.title_sequence_finished.connect(_on_title_sequence_finished)
	if GameSession.menu_started:
		_on_title_sequence_finished()


func _on_title_sequence_finished() -> void:
	AudioManager.play_music(GROOVY_BOOTY, MUSIC_FADE_IN_DURATION, MUSIC_VOLUME_DB)


func _on_practice_requested() -> void:
	if _transitioning:
		return
	_transitioning = true
	_fade_out(main_menu, func() -> void:
		_fade_in(practice_menu, practice_menu.focus_first_level))


func _on_practice_closed() -> void:
	if _transitioning:
		return
	_transitioning = true
	_fade_out(practice_menu, func() -> void:
		_fade_in(main_menu, main_menu.focus_practice_button))


func _on_credits_requested() -> void:
	if _transitioning:
		return
	_transitioning = true
	_fade_out(main_menu, func() -> void:
		_fade_in(credits_screen, credits_screen.grab_focus))
	credits_screen.reset_crawl()


func _on_credits_closed() -> void:
	if _transitioning:
		return
	_transitioning = true
	_fade_out(credits_screen, func() -> void:
		_fade_in(main_menu, main_menu.focus_credits_button))


func _fade_out(screen: Control, then: Callable) -> void:
	var tween := create_tween()
	tween.tween_property(screen, "modulate:a", 0.0, SCREEN_FADE_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		screen.visible = false
		screen.modulate.a = 1.0
		_transitioning = false
		then.call())


func _fade_in(screen: Control, focus: Callable) -> void:
	screen.modulate.a = 0.0
	screen.visible = true
	var tween := create_tween()
	tween.tween_property(screen, "modulate:a", 1.0, SCREEN_FADE_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(focus)
