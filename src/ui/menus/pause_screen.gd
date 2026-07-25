extends MarginContainer


@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	if visible and resume_button != null:
		resume_button.grab_focus()