extends Label

var speeds = [
	"slow",
	"warmup",
	"classic",
] 


func _ready():
	self.text = speeds[2]


func _on_speed_slider_value_changed(value: float) -> void:
	var index = int(value * (len(speeds) - 1))
	self.text = speeds[index]
