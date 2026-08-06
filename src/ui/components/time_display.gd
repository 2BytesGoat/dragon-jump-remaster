class_name TimeDisplay
extends MarginContainer

## TimeDisplay
## Display-only run timer label. The clock lives in RunTimer (main scene);
## this node just renders the value it is told to show.

@onready var time_label = $TimeLabel


func _ready() -> void:
	reset()


func set_time(time: float) -> void:
	time_label.text = Utils.format_time(time)


func reset() -> void:
	time_label.text = "00:00.00"
