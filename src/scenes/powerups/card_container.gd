extends Panel

@onready var card_scene: PackedScene = preload("res://src/scenes/powerups/card_scene.tscn")
@export var margin_shift: Array = [-10, 0, 0, 10]
var is_splitscreen: bool = false
var _cards: Dictionary = {}
var _last_pickup_position: Vector2 = Vector2.ZERO


func shift_card_positions(backward: bool = false) -> void:
	var offset: Array = margin_shift.duplicate()
	if backward:
		for i in range(offset.size()):
			offset[i] *= -1
	for child in self.get_children():
		child.shift_by(offset)


func _on_player_picked_powerup(powerup_name: String, id: int, pickup_global_position: Vector2) -> void:
	_last_pickup_position = pickup_global_position
	var card_object: CardUI = card_scene.instantiate()
	card_object.is_splitscreen = is_splitscreen
	card_object.name = str(id)
	self.add_child(card_object)
	_cards[id] = card_object
	card_object.draw(powerup_name, false, _last_pickup_position)
	shift_card_positions()


func _on_player_used_powerup(id: int) -> void:
	shift_card_positions(true)
	var card := _cards.get(id) as CardUI
	if card:
		_cards.erase(id)
		remove_child(card)
		card.queue_free()
