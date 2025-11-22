extends MarginContainer

@onready var bar_texture: Panel = $Texture
@onready var icon_container: Node = $IconContainer

var x_start: float = 0.0
var x_length: float = 0.0


func _ready() -> void:
	var x_end = self.get_theme_constant("margin_right")
	x_start = self.get_theme_constant("margin_left")
	x_length = self.size.x - x_start - x_end


func update_player_progress(progress_data: Dictionary) -> void:
	for node in icon_container.get_children():
		var progress = progress_data.get(node.name)
		if progress:
			set_progress(node, progress)


func set_progress(node: Sprite2D, progress: float) -> void:
	var pixel_progress = x_length * progress
	node.position.x = x_start + pixel_progress
