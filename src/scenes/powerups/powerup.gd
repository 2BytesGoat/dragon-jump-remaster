class_name Powerup
extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var type: String = ""
var color: Color = Color()
var thickness: float = 1.0


func _ready() -> void:
	sprite.material.set_shader_parameter("replace_0", color)


func init(args: Array) -> void:
	type = args[0]
	color = Constants.POWERUPS[type]["color"]


func pickup() -> void:
	visible = false
	collision.call_deferred("set_disabled", true)
	sfx.play()


func consume() -> void:
	visible = true
	sprite.material.set_shader_parameter("replace_0", Color(1.0, 1.0, 1.0, 1.0))
	sprite.material.set_shader_parameter("thickness", 0.0)
	animation_player.play("Spawn")


func reset() -> void:
	visible = true
	sprite.material.set_shader_parameter("replace_0", color)
	sprite.material.set_shader_parameter("thickness", thickness)
	collision.disabled = false
	animation_player.play("RESET")


func _on_animation_ended() -> void:
	reset()
