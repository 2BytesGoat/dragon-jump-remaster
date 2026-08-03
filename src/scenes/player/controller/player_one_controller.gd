class_name PlayerOneController
extends PlayerCharacterController


func _input(event: InputEvent) -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if not is_instance_valid(player):
		return
	if event.is_action_pressed("player_one_jump"):
		jump_command.execute(player, JumpCommand.Params.new(true))
	elif event.is_action_released("player_one_jump"):
		jump_command.execute(player, JumpCommand.Params.new(false))
	elif event.is_action_pressed("player_one_reset"):
		Utils.instance_scene_on_main(player.despawn_smoke, player.global_position)
		reset_command.execute(player)
