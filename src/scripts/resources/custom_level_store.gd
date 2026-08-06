class_name CustomLevelStore
extends RefCounted

## Static helper that persists player-imported custom levels to user:// as a
## JSON dictionary of { id: { "name": String, "code": String } }.

const STORE_PATH := "user://custom_levels.json"

static var _levels: Dictionary = {}
static var _loaded := false


static func _load() -> void:
	if _loaded:
		return
	_loaded = true

	if not FileAccess.file_exists(STORE_PATH):
		return
	var file := FileAccess.open(STORE_PATH, FileAccess.READ)
	if file == null:
		push_warning("CustomLevelStore: failed to open %s" % STORE_PATH)
		return
	var raw := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed is Dictionary:
		_levels = parsed
	else:
		push_warning("CustomLevelStore: corrupt store file; starting empty.")


static func _save() -> void:
	var file := FileAccess.open(STORE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("CustomLevelStore: failed to write %s" % STORE_PATH)
		return
	file.store_string(JSON.stringify(_levels, "\t"))
	file.close()


static func get_all() -> Array[Dictionary]:
	_load()
	var entries: Array[Dictionary] = []
	for id in _levels.keys():
		var entry: Dictionary = _levels[id]
		entries.append({
			"id": id,
			"name": entry.get("name", id),
			"code": entry.get("code", ""),
		})
	entries.sort_custom(_sort_by_name)
	return entries


static func has_level(id: String) -> bool:
	_load()
	return _levels.has(id)


static func get_level(id: String) -> Dictionary:
	_load()
	return _levels.get(id, {})


static func add_level(id: String, name: String, code: String) -> bool:
	if id.is_empty() or code.is_empty():
		return false
	_load()
	_levels[id] = {"name": name, "code": code}
	_save()
	return true


static func remove_level(id: String) -> void:
	_load()
	if _levels.erase(id):
		_save()


static func _sort_by_name(a: Dictionary, b: Dictionary) -> bool:
	return str(a.get("name", "")) < str(b.get("name", ""))
