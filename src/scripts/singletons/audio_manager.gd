extends Node

## AudioManager
## Cross-scene music and global bus mixing only.
## Local one-shots live in scenes.

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	_music_player.bus = &"Music"


func play_music(stream: AudioStream, crossfade: float = 0.0) -> void:
	if _music_player.playing and _music_player.stream == stream:
		return
	
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var db = linear_to_db(clamp(linear_volume, 0.0, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db)