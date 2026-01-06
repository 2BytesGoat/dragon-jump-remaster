extends Button


func _on_mouse_entered() -> void:
	self.grab_focus()


func _on_mouse_exited() -> void:
	self.release_focus()
