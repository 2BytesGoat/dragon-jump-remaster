extends Button

@onready var label = %Label


var button_label: String = "tmp" : set = _on_button_label_changed

func _on_button_label_changed(new_label: String) -> void:
	label.text = new_label
