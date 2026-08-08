extends CanvasLayer

## CRTScreenEffect
## Full-screen CRT overlay. Listens to the Settings autoload and applies the
## CRT and scanline toggles itself, so any scene that instantiates this widget
## gets the right behavior without extra wiring.

@onready var _color_rect: ColorRect = $ColorRect


func _ready() -> void:
	_apply_crt_setting()
	_apply_scanlines_setting()
	if not Settings.crt_toggled.is_connected(_on_crt_toggled):
		Settings.crt_toggled.connect(_on_crt_toggled)
	if not Settings.scanlines_toggled.is_connected(_on_scanlines_toggled):
		Settings.scanlines_toggled.connect(_on_scanlines_toggled)


func _apply_crt_setting() -> void:
	visible = Settings.crt_enabled


func _apply_scanlines_setting() -> void:
	if _color_rect != null and _color_rect.material is ShaderMaterial:
		_color_rect.material.set_shader_parameter("scanlines_enabled", Settings.scanlines_enabled)


func _on_crt_toggled(enabled: bool) -> void:
	visible = enabled


func _on_scanlines_toggled(enabled: bool) -> void:
	_apply_scanlines_setting()
