extends Resource
class_name GameData

## In-memory progress schema.
## Serialized to an encrypted binary file with an HMAC checksum.

const SAVE_VERSION := 1

@export var save_version: int = SAVE_VERSION
@export var player_name = Constants.DEFAULT_PLAYER_NAME
@export var levels = {}


func migrate() -> void:
	if save_version < SAVE_VERSION:
		save_version = SAVE_VERSION
	# Future migrations go here.

