extends Characters
class_name ranged_enemy
var movement_end_pos: Vector2
var current_dangering_locations:Array = []

func _to_string():
	return "Ranged enemy at %s" % str(get_parent().world_to_map(position))

func move_on_path(path: PoolVector2Array):
	#Move along a path
	get_parent().remove_dangerous_tiles(current_dangering_locations)
	for step in path:
		tween.interpolate_property(self, "position", position, step + Vector2(0, 32), 1.0, Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_completed")
	show_what_it_will_hit()
	get_parent().update_all_characters_info()
	emit_signal("movement_done")

func get_pushed(direction:Vector2):
	#Character gets pushed in a direction
	get_parent().remove_dangerous_tiles(current_dangering_locations)
	var map_location = get_parent().world_to_map(position)
	var end_location = map_location + direction
	if map_info.is_location_in_players(end_location):
		var other_player = map_info.get_player_at_location(end_location)
		take_damage(1)
		other_player.take_damage(1)
	elif map_info.is_location_in_enemies(end_location):
		var other_enemy = map_info.get_enemy_at_location(end_location)
		take_damage(1)
		if is_instance_valid(other_enemy):
			other_enemy.take_damage(1)
	elif map_info.walkable_tiles.has(end_location):
		var movement_path = get_parent().find_character_path(self, end_location)
		move_on_path(movement_path)
		target += direction
	elif map_info.is_location_a_building(end_location):
		map_info.building_got_damaged()
		take_damage(1)
	elif not map_info.walkable_tiles.has(end_location):
		take_damage(1)

func find_position():
	#Find a target and a position to shoot from.
	var buildings:Array = map_info.map_info.keys()
	var players_locations = map_info.player_locations.values()
	var walkable_tiles = map_info.walkable_tiles.duplicate(true)
	var target_standing_dict = {}
	for building in buildings:
		target_standing_dict[building] = find_locations_to_shoot_from(building, walkable_tiles)
	for player_loc in players_locations:
		target_standing_dict[player_loc] = find_locations_to_shoot_from(player_loc, walkable_tiles)
	for location in target_standing_dict:
		if target_standing_dict[location] == []:
			target_standing_dict.erase(location)
	var too_far_targets_removed = remove_too_far_targets(target_standing_dict)
	randomize()
	var all_possible_targets = too_far_targets_removed.keys()
	if all_possible_targets.size() == 0:
		target = Vector2()
		movement_end_pos = get_parent().world_to_map(position)
		return
	var target_id = randi() % all_possible_targets.size()
	target = all_possible_targets[target_id]
	var all_mov_positions = too_far_targets_removed[target]
	var mov_position_id = randi() % all_mov_positions.size()
	movement_end_pos = all_mov_positions[mov_position_id]

func remove_too_far_targets(target_standing_dict:Dictionary) -> Dictionary:
	#Remove all the locations that are too far away.
	var dummy_dict = target_standing_dict.duplicate(true)
	for target in target_standing_dict:
		var target_locations:Array = target_standing_dict[target]
		for location in target_locations:
			var path_length:int = get_parent().find_path_length(self, location)
			if path_length > 5 or path_length < 1:
				dummy_dict[target].erase(location)
		if dummy_dict[target].size() == 0:
			dummy_dict.erase(target)
	return dummy_dict

func _on_healthbar_death():
	map_info.enemy_locations.erase(self)
	get_parent().character_death(self.position)
	get_parent().remove_dangerous_tiles(current_dangering_locations)
	queue_free()

func find_locations_to_shoot_from(shooting_target:Vector2, all_standing_locations:Array)-> Array:
	var possible_locations = []
	var test_vector = shooting_target + Vector2.UP
	while test_vector in all_standing_locations and not map_info.is_location_in_players(test_vector) and not map_info.is_location_in_enemies(test_vector):
		possible_locations.append(test_vector)
		test_vector += Vector2.UP 
	test_vector = shooting_target + Vector2.RIGHT
	while test_vector in all_standing_locations and not map_info.is_location_in_players(test_vector) and not map_info.is_location_in_enemies(test_vector):
		possible_locations.append(test_vector)
		test_vector += Vector2.RIGHT
	test_vector = shooting_target + Vector2.DOWN
	while test_vector in all_standing_locations and not map_info.is_location_in_players(test_vector) and not map_info.is_location_in_enemies(test_vector):
		possible_locations.append(test_vector)
		test_vector += Vector2.DOWN
	test_vector = shooting_target + Vector2.LEFT
	while test_vector in all_standing_locations and not map_info.is_location_in_players(test_vector) and not map_info.is_location_in_enemies(test_vector):
		possible_locations.append(test_vector)
		test_vector += Vector2.LEFT
	return possible_locations   

func attack_the_target():
	#Spawn a projectile that does damage.
	if target == Vector2():
		return
	get_parent().shoot_ranged_projectile(position,target)

func show_what_it_will_hit():
	var current_map_location = get_parent().world_to_map(position)
	var direction:Vector2 = (target - current_map_location).normalized()
	var buildings:Array = map_info.map_info.keys()
	var players_locations = map_info.player_locations.values()
	var enemy_locations = map_info.enemy_locations.values()
	var walkable_tiles = map_info.walkable_tiles.duplicate(true)
	var dangerous_tiles = []
	var test_location:Vector2 = current_map_location + direction
	dangerous_tiles.append(test_location)
	while walkable_tiles.has(test_location) and not buildings.has(test_location) and not players_locations.has(test_location) and not enemy_locations.has(test_location):
		test_location += direction
		dangerous_tiles.append(test_location)
	current_dangering_locations = dangerous_tiles
	get_parent().add_dangerous_tiles(dangerous_tiles)
