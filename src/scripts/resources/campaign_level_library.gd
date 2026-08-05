class_name CampaignLevelLibrary
extends RefCounted

## Static helper that loads all CampaignLevelData resources from
## res://resources/level_data/ once and exposes them by level_id.

const LEVEL_DATA_PATH := "res://resources/level_data/"

static var _levels: Dictionary = {}
static var _loaded := false


static func _load_levels() -> void:
	if _loaded:
		return
	_loaded = true

	var files: PackedStringArray = ResourceLoader.list_directory(LEVEL_DATA_PATH)
	if files.is_empty():
		push_error("CampaignLevelLibrary: failed to list %s" % LEVEL_DATA_PATH)
		return

	for file_name in files:
		if file_name.ends_with("/") or not file_name.ends_with(".tres"):
			continue
		if file_name.begins_with("_"):
			continue

		var resource_path := LEVEL_DATA_PATH.path_join(file_name)
		var resource := ResourceLoader.load(resource_path)
		if resource is CampaignLevelData:
			_levels[resource.level_id] = resource
		else:
			push_warning("CampaignLevelLibrary: skipping non-level resource %s" % resource_path)


static func get_level(level_id: String) -> CampaignLevelData:
	_load_levels()
	return _levels.get(level_id)


static func has_level(level_id: String) -> bool:
	_load_levels()
	return _levels.has(level_id)


static func get_all_level_ids() -> Array:
	_load_levels()
	var ids: Array = _levels.keys()
	ids.sort_custom(_compare_level_ids)
	return ids


static func _compare_level_ids(a: String, b: String) -> bool:
	var parts_a := a.split("-")
	var parts_b := b.split("-")
	for i in range(min(parts_a.size(), parts_b.size())):
		var num_a := int(parts_a[i])
		var num_b := int(parts_b[i])
		if num_a != num_b:
			return num_a < num_b
	return parts_a.size() < parts_b.size()


static func get_next_level(level_id: String) -> String:
	var all_level_ids := get_all_level_ids()
	var next_index := all_level_ids.find(level_id) + 1
	if next_index >= len(all_level_ids):
		return ""
	return all_level_ids[next_index]
