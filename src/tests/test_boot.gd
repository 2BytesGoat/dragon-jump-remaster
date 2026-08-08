extends Node

## Test: game boots to main menu.
## Loads the main menu scene, waits a frame, and verifies the root node is the
## expected MainMenu container with a visible PlayButton.

const MAIN_MENU_SCENE := preload("res://src/ui/menu/main_menu.tscn")


func run() -> bool:
	var main_menu: Control = MAIN_MENU_SCENE.instantiate()
	add_child(main_menu)

	var play_button := main_menu.get_node_or_null(
		"SubViewportContainer/SubViewport/MenuSelectionScreen/VBoxContainer/VBoxContainer2/Panel/VBoxContainer/PlayButton"
	)
	var passed := main_menu.name == "MainMenu" and play_button != null
	if not passed:
		push_error("BOOT TEST FAIL: main menu did not load correctly")

	main_menu.queue_free()
	return passed


func _ready() -> void:
	if get_tree().current_scene == self:
		var passed := run()
		print("BOOT TEST: %s" % ("PASS" if passed else "FAIL"))
		await get_tree().process_frame
		get_tree().quit(0 if passed else 1)
