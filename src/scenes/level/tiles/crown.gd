extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func pickup() -> void:
	animation_player.play("RESET")


func drop() -> void:
	animation_player.play("default")
