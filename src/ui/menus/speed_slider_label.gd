extends Label

var speeds = [
	"slow",
	"warmup",
	"classic",
	"advanced",
	"turbo"
] 


func _ready():
	self.text = speeds[2]


func _on_speed_slider_value_changed(value: float) -> void:
	var index = int(value * 4)
	self.text = speeds[index]
