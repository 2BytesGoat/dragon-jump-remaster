extends Control

## CustomLevelsMenu
## Browse imported custom levels, import new ones by pasting a level code,
## play them, or delete them. Returns to the main menu.

const CUSTOM_LEVEL_ID_PREFIX := "custom_"

@onready var level_list = %LevelList
@onready var empty_label = %EmptyLabel
@onready var import_code_edit = %ImportCodeEdit
@onready var import_name_edit = %ImportNameEdit
@onready var import_feedback = %ImportFeedbackLabel
@onready var import_panel = %ImportPanel
@onready var play_button: Button = %PlayButton
@onready var delete_button: Button = %DeleteButton
@onready var import_button: Button = %ImportButton
@onready var back_button: Button = %BackButton

@export var main_menu_scene: PackedScene
@export var single_player_scene: PackedScene

var _selected_id := ""
var _selected_code := ""


func _ready() -> void:
	import_panel.visible = false
	_refresh_list()
	_import_button_focus()


func _refresh_list() -> void:
	for child in level_list.get_children():
		level_list.remove_child(child)
		child.queue_free()

	var entries := CustomLevelStore.get_all()
	empty_label.visible = entries.is_empty()

	for entry in entries:
		var button := Button.new()
		button.text = entry.name
		button.pressed.connect(_on_level_pressed.bind(entry.id, entry.code))
		level_list.add_child(button)

	_selected_id = ""
	_selected_code = ""
	_update_action_buttons()


func _update_action_buttons() -> void:
	var has_selection := _selected_id != ""
	play_button.disabled = not has_selection
	delete_button.disabled = not has_selection


func _on_level_pressed(id: String, code: String) -> void:
	_selected_id = id
	_selected_code = code
	_update_action_buttons()
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	if _selected_code.is_empty():
		return
	GameSession.start_custom_run(_selected_code)
	SceneLoader.go_to(single_player_scene.resource_path)


func _on_delete_button_pressed() -> void:
	if _selected_id.is_empty():
		return
	CustomLevelStore.remove_level(_selected_id)
	_refresh_list()


func _on_import_button_pressed() -> void:
	import_panel.visible = true
	import_feedback.text = ""
	import_code_edit.text = ""
	import_name_edit.text = ""
	import_code_edit.grab_focus()


func _on_import_confirm_pressed() -> void:
	var code := import_code_edit.text.strip_edges()
	var name := import_name_edit.text.strip_edges()
	if code.is_empty():
		import_feedback.text = "ENTER A LEVEL CODE"
		return
	var parsed := LevelCodeParser.parse(code)
	if parsed.instructions.is_empty():
		import_feedback.text = "INVALID LEVEL CODE"
		return
	if name.is_empty():
		name = "Custom Level"
	var id := _next_free_id()
	if not CustomLevelStore.add_level(id, name, code):
		import_feedback.text = "IMPORT FAILED"
		return
	import_panel.visible = false
	_refresh_list()
	_import_button_focus()


func _on_import_cancel_pressed() -> void:
	import_panel.visible = false
	_import_button_focus()


func _on_back_button_pressed() -> void:
	SceneLoader.go_to(main_menu_scene.resource_path)


func _next_free_id() -> String:
	var index := 1
	while CustomLevelStore.has_level(CUSTOM_LEVEL_ID_PREFIX + str(index)):
		index += 1
	return CUSTOM_LEVEL_ID_PREFIX + str(index)


func _import_button_focus() -> void:
	import_button.grab_focus()
