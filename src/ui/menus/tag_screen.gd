extends MarginContainer

@onready var tag_line_edit = %TagLineEdit
var player_tag = "" : set = _on_set_player_tag, get = _on_get_player_tag
var placeholder = Constants.DEFAULT_PLAYER_NAME : set = _on_set_placeholder


func _on_set_player_tag(value: String) -> void:
	tag_line_edit.text = value


func _on_get_player_tag() -> String:
	return tag_line_edit.text


func _on_set_placeholder(value: String) -> void:
	tag_line_edit.placeholder_text = value
