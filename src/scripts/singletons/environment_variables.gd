extends Node

const env_file_path = "res://.env"
var args = {}

func _ready() -> void:
	if FileAccess.file_exists(env_file_path):
		load_env(env_file_path)


func get_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		print(argument)
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.lstrip("--")] = ""

	return arguments


func load_env(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open .env file: %s" % path)
		return

	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == "" or line.begins_with("#"):
			continue
		var parts = line.split("=", false, 1)
		if parts.size() == 2:
			var key = parts[0].strip_edges()
			var value = parts[1].strip_edges()
			if key in RuntimeSecrets:
				RuntimeSecrets[key] = value
	file.close()
