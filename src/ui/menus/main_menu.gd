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

@onready var start_container = %StartContainer
@onready var selection_container = %SelectionContainer
@onready var player_mock: TextureRect = %PlayerMock
@onready var press_key_label: Label = %PressKeyLabel
@onready var play_button: Button = %PlayButton
@onready var jump_sfx: AudioStreamPlayer = $JumpSFX

var _started := false
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
	_player_atlas = player_mock.texture.duplicate()
	player_mock.texture = _player_atlas
	_set_player_frame(IDLE_COORDS)
	_start_blink()


func _unhandled_input(event: InputEvent) -> void:
	if _started:
		return
	if event.is_action_pressed("player_one_jump"):
		get_viewport().set_input_as_handled()
		_start_jump_sequence()


func _start_blink() -> void:
	press_key_label.modulate.a = 1.0
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(press_key_label, "modulate:a", 0.5, BLINK_DURATION / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_blink_tween.tween_property(press_key_label, "modulate:a", 1.0, BLINK_DURATION / 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_player_frame(coords: Vector2) -> void:
	_player_atlas.region = Rect2(coords, FRAME_SIZE)


func _start_jump_sequence() -> void:
	_started = true
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
