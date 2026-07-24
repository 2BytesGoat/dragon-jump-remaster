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
	
	var dir := DirAccess.open(LEVEL_DATA_PATH)
	if not dir:
		push_error("CampaignLevelLibrary: failed to open %s" % LEVEL_DATA_PATH)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() or not file_name.ends_with(".tres"):
			file_name = dir.get_next()
			continue
		
		var resource_path := LEVEL_DATA_PATH.path_join(file_name)
		var resource := ResourceLoader.load(resource_path)
		if resource is CampaignLevelData:
			_levels[resource.level_id] = resource
		else:
			push_warning("CampaignLevelLibrary: skipping non-level resource %s" % resource_path)
		file_name = dir.get_next()


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
