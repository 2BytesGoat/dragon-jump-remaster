extends MarginContainer

## MainMenu
## Title screen: blinking "Press JUMP to Start" with a PlayerMock that jumps
## off-screen on jump input, then reveals the selection container.

const BLINK_DURATION := 2
const FADE_DISTANCE := 64.0
const EXIT_MARGIN := 32.0
const FADE_IN_DURATION := 0.5
const FRAME_SIZE := Vector2(32, 32)

const IDLE_COORDS = Vector2(320, 0)
const JUMP_COORDS = Vector2(448, 0)
const FALL_COORDS = Vector2(416, 0)

signal credits_requested
signal practice_requested
signal title_sequence_finished

@onready var start_container = %StartContainer
@onready var selection_container = %SelectionContainer
@onready var player_mock: TextureRect = %PlayerMock
@onready var press_key_label: Label = %PressKeyLabel
@onready var play_button: Button = %PlayButton
@onready var practice_button: Button = %PracticeButton
@onready var credits_button: Button = %CreditsButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var settings_menu: MarginContainer = $SettingsMenu
@onready var jump_sfx: AudioStreamPlayer = $JumpSFX

var _blink_tween: Tween
var _player_atlas: AtlasTexture
var _jump_velocity := 0.0
var _jump_gravity := 0.0
var _fall_gravity := 0.0
var _start_y := 0.0
var _start_x := 0.0
var _fade_start_y := 0.0
var _transitioning := false


func _ready() -> void:
	start_container.visible = true
	selection_container.visible = false
	if GameSession.menu_started:
		_skip_title_sequence()
		return
	_player_atlas = player_mock.texture.duplicate()
	player_mock.texture = _player_atlas
	_set_player_frame(IDLE_COORDS)
	_start_blink()


func _skip_title_sequence() -> void:
	start_container.visible = false
	selection_container.visible = true
	call_deferred("_focus_play_button")


func _focus_play_button() -> void:
	play_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not GameSession.menu_started:
		if event.is_action_pressed("player_one_jump"):
			get_viewport().set_input_as_handled()
			GameSession.start_menu()
			_start_jump_sequence()
		return
	if selection_container.visible and get_viewport().gui_get_focus_owner() == null:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			get_viewport().set_input_as_handled()
			play_button.grab_focus()


func _start_blink() -> void:
	press_key_label.modulate.a = 1.0
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(press_key_label, "modulate:a", 0.5, BLINK_DURATION / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_blink_tween.tween_property(press_key_label, "modulate:a", 1.0, BLINK_DURATION / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_player_frame(coords: Vector2) -> void:
	_player_atlas.region = Rect2(coords, FRAME_SIZE)


func _start_jump_sequence() -> void:
	if _blink_tween != null and _blink_tween.is_valid():
		_blink_tween.kill()
	press_key_label.modulate.a = 1.0
	jump_sfx.play()
	_set_player_frame(JUMP_COORDS)

	# Free the mock from container layout so the jump arc can move it freely.
	var screen_pos := player_mock.global_position
	player_mock.top_level = true
	player_mock.position = screen_pos

	var params := Constants.PHYSICS_PARAMS
	_jump_velocity = -2.0 * params.jump_height / params.jump_time_to_peak
	_jump_gravity = 2.0 * params.jump_height / (params.jump_time_to_peak ** 2)
	_fall_gravity = 2.0 * params.jump_height / (params.jump_time_to_descent ** 2)
	_start_y = player_mock.position.y
	_start_x = player_mock.position.x

	var viewport_height := get_viewport_rect().size.y
	_fade_start_y = viewport_height - player_mock.size.y
	var fall_distance := maxf(0.0, viewport_height + EXIT_MARGIN - (player_mock.position.y + player_mock.size.y) + params.jump_height)
	var fall_time := sqrt(2.0 * fall_distance / _fall_gravity)
	var total_time := params.jump_time_to_peak + fall_time

	var tween := create_tween()
	tween.tween_method(_jump_arc_step, 0.0, total_time, total_time)
	tween.tween_callback(_on_jump_sequence_finished)


func _jump_arc_step(t: float) -> void:
	var params := Constants.PHYSICS_PARAMS
	var y := _start_y + _jump_velocity * t
	if t <= params.jump_time_to_peak:
		y += 0.5 * _jump_gravity * t * t
	else:
		var t_fall := t - params.jump_time_to_peak
		y = _start_y + _jump_velocity * params.jump_time_to_peak \
			+ 0.5 * _jump_gravity * params.jump_time_to_peak * params.jump_time_to_peak \
			+ 0.5 * _fall_gravity * t_fall * t_fall
		_set_player_frame(FALL_COORDS)
	player_mock.position.y = y
	player_mock.position.x = _start_x + Constants.PHYSICS_PARAMS.max_speed * t
	if y > _fade_start_y:
		player_mock.modulate.a = maxf(0.0, 1.0 - (y - _fade_start_y) / FADE_DISTANCE)


func _on_jump_sequence_finished() -> void:
	start_container.visible = false
	start_container.modulate.a = 1.0
	selection_container.visible = true
	selection_container.modulate.a = 0.0
	title_sequence_finished.emit()
	var tween := create_tween()
	tween.tween_property(selection_container, "modulate:a", 1.0, FADE_IN_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_on_selection_faded_in)


func _on_selection_faded_in() -> void:
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	if _transitioning:
		return
	ArcadeDirector.start_arcade_run()
	SceneLoader.go_to("res://main.tscn")
	_transitioning = true


func _on_credits_button_pressed() -> void:
	credits_requested.emit()


func _on_practice_button_pressed() -> void:
	practice_requested.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	settings_menu.visible = true
	_set_selection_focusable(false)
	var close_button := settings_menu.find_child("CloseButton", true, false)
	if close_button is Button:
		close_button.grab_focus()


func _on_settings_menu_close_me() -> void:
	_set_selection_focusable(true)
	settings_menu.visible = false
	settings_button.grab_focus()


func _set_selection_focusable(enabled: bool) -> void:
	for child in selection_container.find_children("*", "Control", true, false):
		if child.focus_mode != Control.FOCUS_NONE:
			child.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE


func _on_github_button_pressed() -> void:
	OS.shell_open(Constants.GITHUB_URL)


func _on_discord_button_pressed() -> void:
	OS.shell_open(Constants.DISCORD_URL)


func _on_steam_button_pressed() -> void:
	OS.shell_open(Constants.STEAM_URL)


func focus_credits_button() -> void:
	credits_button.grab_focus()


func focus_practice_button() -> void:
	practice_button.grab_focus()
