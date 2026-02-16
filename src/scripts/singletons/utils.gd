extends Node


func get_weighted_array_item(array: Array, weights=[]) -> Vector2i:
	if array.is_empty():
		return Vector2i(-1, -1)

	if array.size() == 1:
		return array[0]

	var sum_of_weight = 0.0
	for i in weights:
		sum_of_weight += i
	
	var rnd = randf() * sum_of_weight
	for i in range(array.size()):
		if rnd < weights[i]:
			return array[i]
		rnd -= weights[i]

	# Fallback (shouldn’t happen)
	return array[0]


func instance_scene_on_main(scene, position, rotation=0.0, scale=Vector2.ONE):
	var level_scenes = get_tree().get_nodes_in_group("Level")
	if level_scenes.size() == 0:
		print("can't instance scene, level scene missing")
		return
	
	var level = level_scenes[0]
	var instance = scene.instantiate()
	level.add_child.call_deferred(instance)
	instance.rotation = rotation
	instance.scale = scale
	instance.global_position = position
	return instance


func format_time(time_sec: float) -> String:
	var total_cs = int(time_sec * 100.0)
	total_cs = min(total_cs, 99 * 60 * 100 + 59 * 100 + 99)

	var minutes = total_cs / 6000
	var seconds = (total_cs / 100) % 60
	var ms = total_cs % 100

	return "%02d:%02d.%02d" % [minutes, seconds, ms]


func is_allowed_player_name(player_name: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[A-Za-z ]+$")
	return regex.search(player_name) != null


func generate_dijkstra_map(grid_size: Vector2i, costs: Array, target: Vector2i) -> Array:
	# Initialize distance map with infinity
	var dist_map = []
	for x in range(grid_size.x):
		var column = []
		column.resize(grid_size.y)
		column.fill(INF)
		dist_map.append(column)
	
	# The Frontier (Queue for BFS)
	var queue = [target]
	dist_map[target.x][target.y] = 0.0
	
	var neighbors = [
		Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]

	while queue.size() > 0:
		var current = queue.pop_front()
		var current_dist = dist_map[current.x][current.y]
		
		for offset in neighbors:
			var next = current + offset
			
			# Boundary and Wall check
			if next.x < 0 or next.x >= grid_size.x or next.y < 0 or next.y >= grid_size.y:
				continue
				
			var tile_cost = costs[next.x][next.y]
			if tile_cost == INF: continue # It's a wall
			
			# Calculate new distance (Diagonal cost = 1.4, Cardinal = 1.0)
			var move_cost = 1.414 if (offset.x != 0 and offset.y != 0) else 1.0
			var new_dist = current_dist + (tile_cost * move_cost)
			
			# If we found a shorter path to this tile, update and add to queue
			if new_dist < dist_map[next.x][next.y]:
				dist_map[next.x][next.y] = new_dist
				queue.push_back(next)
				
	return dist_map
