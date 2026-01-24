extends MarginContainer

@onready var tag_line_edit = %TagLineEdit
var player_tag = "" : get = _on_get_player_tag


func _on_get_player_tag() -> String:
	return tag_line_edit.text
