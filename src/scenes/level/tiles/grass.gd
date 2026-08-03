extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var skewValue := 30
@export var bendGrassnimationSpeed = 0.3
@export var grassReturnAnimationSpeed = 5.0


func _ready() -> void:
	var atlas_texture := sprite_2d.texture as AtlasTexture
	if atlas_texture:
		atlas_texture = atlas_texture.duplicate()
		sprite_2d.texture = atlas_texture
		var region := atlas_texture.region
		region.position.x = region.position.x + (randi() % 3) * region.size.x
		atlas_texture.region = region


func _on_area_entered(area: Area2D) -> void:
	var direction = global_position.direction_to(area.global_position)
	var sprite_skew : int = -direction.x * skewValue
	
	var tween = create_tween()
	tween.tween_property(
		sprite_2d.material, 
		"shader_parameter/skew", 
		sprite_skew, 
		bendGrassnimationSpeed
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
	tween.tween_property(
		sprite_2d.material, 
		"shader_parameter/skew", 
		0.0, 
		grassReturnAnimationSpeed
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
