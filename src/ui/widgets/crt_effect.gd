extends CanvasLayer

## CRTScreenEffect
## Full-screen CRT overlay. Listens to the Settings autoload and applies the
## CRT toggle itself, so any scene that instantiates this widget gets the
## right behavior without extra wiring.

@onready var _color_rect: ColorRect = $ColorRect


func _ready() -> void:
	_apply_crt_setting()
	if not Settings.crt_toggled.is_connected(_on_crt_toggled):
		Settings.crt_toggled.connect(_on_crt_toggled)


func _apply_crt_setting() -> void:
	visible = Settings.crt_enabled


func _on_crt_toggled(enabled: bool) -> void:
	visible = enabled
