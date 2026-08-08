extends Control

## MainScreen
## Root of the main menu: hosts the MainMenu and the CreditsScreen overlay,
## fading the credits in on request and back to the menu on close.

const SCREEN_FADE_IN_DURATION := 0.5
const MUSIC_FADE_IN_DURATION := 0.5
const MUSIC_VOLUME_DB := -15.0

const GROOVY_BOOTY := preload("res://assets/music/Groovy booty.ogg")

@onready var main_menu: MarginContainer = $MainMenu
@onready var practice_menu: MarginContainer = $PracticeMenu
@onready var credits_screen: MarginContainer = %CreditsScreen


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
	main_menu.visible = false
	practice_menu.visible = true
	practice_menu.focus_first_level()


func _on_practice_closed() -> void:
	practice_menu.visible = false
	main_menu.visible = true
	main_menu.focus_practice_button()


func _on_credits_requested() -> void:
	main_menu.visible = false
	credits_screen.modulate.a = 0.0
	credits_screen.visible = true
	credits_screen.reset_crawl()
	credits_screen.grab_focus()
	var tween := create_tween()
	tween.tween_property(credits_screen, "modulate:a", 1.0, SCREEN_FADE_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_credits_closed() -> void:
	main_menu.visible = true
	main_menu.focus_credits_button()
