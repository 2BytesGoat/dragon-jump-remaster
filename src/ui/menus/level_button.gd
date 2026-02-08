extends Button

@onready var label = %Label
@onready var medal_icon = %MedalIcon
var button_label: String = "tmp" : set = _on_button_label_changed



func set_button_disabled(value: bool) -> void:
	self.disabled = value
	medal_icon.visible = not value

func _on_button_label_changed(new_label: String) -> void:
	label.text = new_label
	var level_data: LevelData = SaveManager.get_level_data(self.name)
	if not level_data:
		return
	
	medal_icon.visible = level_data.attempts != 0
	medal_icon.modulate = Constants.MEDAL_COLORS[level_data.progress_milestone]
