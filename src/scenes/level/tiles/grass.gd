extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

@export var skewValue := 30
@export var bendGrassnimationSpeed = 0.3
@export var grassReturnAnimationSpeed = 5.0


func _on_area_entered(area: Area2D) -> void:
	var direction = global_position.direction_to(area.global_position)
	var skew : int = -direction.x * skewValue
	
	var tween = create_tween()
	tween.tween_property(
		sprite_2d.material, 
		"shader_parameter/skew", 
		skew, 
		bendGrassnimationSpeed
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
	tween.tween_property(
		sprite_2d.material, 
		"shader_parameter/skew", 
		0.0, 
		grassReturnAnimationSpeed
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
