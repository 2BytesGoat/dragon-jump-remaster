extends Node

## AudioManager
## Cross-scene music and global bus mixing only.
## Local one-shots live in scenes.

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.bus = &"Music"


func play_music(stream: AudioStream, _crossfade: float = 0.0) -> void:
	if _music_player.playing and _music_player.stream == stream:
		return
	
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_warning("AudioManager: bus '%s' does not exist. Valid buses: %s" % [bus_name, _get_bus_names()])
		return
	var db = linear_to_db(clamp(linear_volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(bus_index, db)


func _get_bus_names() -> PackedStringArray:
	var result: PackedStringArray = []
	for i in AudioServer.bus_count:
		result.append(AudioServer.get_bus_name(i))
	return result
