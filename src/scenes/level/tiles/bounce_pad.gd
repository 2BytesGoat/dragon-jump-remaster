class_name BouncePad
extends Area2D

enum Facing {
	UP,
	DOWN,
	RIGHT,
	LEFT
}

const FACING_DATA := {
	Facing.UP:    { dir = Vector2.UP,    rot = 0 },
	Facing.DOWN:  { dir = Vector2.DOWN,  rot = 180 },
	Facing.RIGHT: { dir = Vector2.RIGHT, rot = 90 },
	Facing.LEFT:  { dir = Vector2.LEFT,  rot = 270 },
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing_direction: Vector2 = Vector2.UP

func init(args: Array) -> void:
	var data = FACING_DATA.get(args[0], FACING_DATA[Facing.UP])
	facing_direction = data.dir
	rotation_degrees = data.rot

func _on_area_entered(_area: Area2D) -> void:
	animated_sprite.play("default")
