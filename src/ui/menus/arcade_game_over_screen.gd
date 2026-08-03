extends MarginContainer

## ArcadeGameOverScreen
## Game-over / run-complete screen for arcade mode. The player cycles A-Z
## through 5 letter slots (arcade-style initials) using a single joystick
## (arcade_left/right move the cursor, arcade_up/down cycle letters), then
## confirms with jump (player_one_jump / ui_accept) to save, or R
## (player_one_reset) to skip. Both paths lead to the local top-10
## leaderboard with the submitted entry highlighted, plus TRY AGAIN / QUIT
## buttons.

const TAG_LENGTH := 5
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ "

@onready var score_label = %ScoreLabel
@onready var levels_label = %LevelsLabel
@onready var new_high_score_label = %NewHighScoreLabel
@onready var hint_label = %HintLabel
@onready var save_hint_label = %SaveHintLabel
@onready var letter_edit_container = %LetterEditContainer
@onready var leaderboard_container = %LeaderboardContainer
@onready var leaderboard_entries_box = %LeaderboardEntriesBox
@onready var buttons_row = %ButtonsRow
@onready var try_again_button: Button = %TryAgainButton
@onready var quit_button: Button = %QuitButton

var _tag: Array[int] = []
var _cursor: int = 0
var _summary: Dictionary = {}
var _mode: String = "edit"
var _letter_labels: Array[Label] = []
var _hint_tween: Tween = null


func _ready() -> void:
	_letter_labels = []
	for child in letter_edit_container.get_children():
		if child is Label:
			_letter_labels.append(child)
	_tag = []
	for i in range(TAG_LENGTH):
		_tag.append(0)
	_cursor = 0
	_mode = "edit"
	leaderboard_container.visible = false
	buttons_row.visible = false
	letter_edit_container.visible = true
	hint_label.visible = true
	save_hint_label.visible = true
	_start_hint_blink()


func _exit_tree() -> void:
	_stop_hint_blink()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not is_inside_tree():
		return
	if _mode == "edit":
		_handle_edit_input(event)
	elif _mode == "leaderboard":
		_handle_leaderboard_input(event)


func _handle_edit_input(event: InputEvent) -> void:
	if event.is_action_pressed("arcade_left"):
		_move_cursor(-1)
		accept_event()
	elif event.is_action_pressed("arcade_right"):
		_move_cursor(1)
		accept_event()
	elif event.is_action_pressed("arcade_up"):
		_cycle_letter(1)
		accept_event()
	elif event.is_action_pressed("arcade_down"):
		_cycle_letter(-1)
		accept_event()
	elif event.is_action_pressed("player_one_jump") or event.is_action_pressed("ui_accept"):
		_submit_name()
		accept_event()
	elif event.is_action_pressed("player_one_reset"):
		_skip_name()
		accept_event()


func _handle_leaderboard_input(event: InputEvent) -> void:
	if event.is_action_pressed("player_one_reset"):
		_exit_to_menu()
		accept_event()


func show_run_summary(summary: Dictionary) -> void:
	_summary = summary
	score_label.text = "%08d" % int(summary.get("score", 0))
	levels_label.text = "%02d" % int(summary.get("levels_reached", 1))
	new_high_score_label.visible = int(summary.get("score", 0)) > SaveManager.get_arcade_high_score()
	_mode = "edit"
	leaderboard_container.visible = false
	buttons_row.visible = false
	letter_edit_container.visible = true
	hint_label.visible = true
	save_hint_label.visible = true
	_refresh_letters()
	_start_hint_blink()


func get_entered_tag() -> String:
	var result := ""
	for i in range(TAG_LENGTH):
		result += LETTERS[_tag[i]]
	return result


func _move_cursor(offset: int) -> void:
	_cursor = wrapi(_cursor + offset, 0, TAG_LENGTH)
	_refresh_letters()


func _cycle_letter(offset: int) -> void:
	_tag[_cursor] = wrapi(_tag[_cursor] + offset, 0, LETTERS.length())
	_refresh_letters()


func _refresh_letters() -> void:
	for i in range(TAG_LENGTH):
		if i >= _letter_labels.size():
			break
		var text := LETTERS[_tag[i]]
		if i == _cursor:
			text = "[" + text + "]"
		_letter_labels[i].text = text


func _submit_name() -> void:
	if _mode != "edit":
		return
	ArcadeDirector.submit_tag(get_entered_tag())
	_show_leaderboard()


func _skip_name() -> void:
	if _mode != "edit":
		return
	ArcadeDirector.skip_run_submission()
	_show_leaderboard()


func _show_leaderboard() -> void:
	_mode = "leaderboard"
	_stop_hint_blink()
	letter_edit_container.visible = false
	hint_label.visible = false
	save_hint_label.visible = false
	leaderboard_container.visible = true
	buttons_row.visible = true
	_render_leaderboard()
	try_again_button.grab_focus()


func _on_try_again_button_pressed() -> void:
	ArcadeDirector.start_arcade_run()
	get_tree().call_deferred("reload_current_scene")


func _on_quit_button_pressed() -> void:
	_exit_to_menu()


func _exit_to_menu() -> void:
	SceneLoader.go_to("res://src/ui/menus/main_menu.tscn")


func _start_hint_blink() -> void:
	_stop_hint_blink()
	save_hint_label.modulate.a = 1.0
	_hint_tween = create_tween().set_loops()
	_hint_tween.tween_property(save_hint_label, "modulate:a", 0.15, 0.5).set_trans(Tween.TRANS_SINE)
	_hint_tween.tween_interval(0.25)
	_hint_tween.tween_property(save_hint_label, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE)
	_hint_tween.tween_interval(0.25)


func _stop_hint_blink() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = null


func _render_leaderboard() -> void:
	for child in leaderboard_entries_box.get_children():
		child.queue_free()

	var entries := SaveManager.get_arcade_leaderboard()
	var new_tag := get_entered_tag()
	var new_score := int(_summary.get("score", 0))
	for i in range(entries.size()):
		var entry := entries[i]
		var is_new = entry.get("tag", "") == new_tag and int(entry.get("score", 0)) == new_score
		var row := HBoxContainer.new()
		var rank := Label.new()
		rank.text = "%02d" % (i + 1)
		rank.custom_minimum_size.x = 24
		rank.add_theme_font_size_override("font_size", 6)
		var name := Label.new()
		name.text = String(entry.get("tag", "?????"))
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name.add_theme_font_size_override("font_size", 6)
		var score := Label.new()
		score.text = "%08d" % int(entry.get("score", 0))
		score.custom_minimum_size.x = 72
		score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score.add_theme_font_size_override("font_size", 6)
		row.add_child(rank)
		row.add_child(name)
		row.add_child(score)
		if is_new:
			row.modulate = Color(1.0, 0.85, 0.3, 1.0)
		leaderboard_entries_box.add_child(row)

	if entries.is_empty():
		var empty := Label.new()
		empty.text = "NO RUNS YET"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		leaderboard_entries_box.add_child(empty)
