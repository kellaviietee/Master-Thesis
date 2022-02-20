extends Resource
signal update_building_health

export(PackedScene) var level_map
var map_info:Dictionary
var walkable_tiles = [] setget set_walkable_tiles
var player_locations = {}
var enemy_locations = {}
var mountain_locations = []


func available_position_next_to_location(position_to_check:Vector2) ->PoolVector2Array:
	#Check an available spot around a specific location
	var available_spots:PoolVector2Array = []
	if walkable_tiles.has(position_to_check + Vector2.UP):
		available_spots.append(position_to_check + Vector2.UP)
	if walkable_tiles.has(position_to_check + Vector2.RIGHT):
		available_spots.append(position_to_check + Vector2.RIGHT)
	if walkable_tiles.has(position_to_check + Vector2.DOWN):
		available_spots.append(position_to_check + Vector2.DOWN)
	if walkable_tiles.has(position_to_check + Vector2.LEFT):
		available_spots.append(position_to_check + Vector2.LEFT)
	return available_spots

func check_for_damage(hit_location:Vector2,damage_amount:int = 1) -> bool:
	#See if an attack was a successful one.
	if player_locations.values().has(hit_location):
		for player in player_locations:
			if player_locations[player] == hit_location:
				player.take_damage(damage_amount)
				return true
	if enemy_locations.values().has(hit_location):
		for enemy in enemy_locations:
			if not is_instance_valid(enemy):
				continue
			if enemy_locations[enemy] == hit_location:
				enemy.take_damage(damage_amount)
				return true
	if map_info.has(hit_location):
		emit_signal("update_building_health", damage_amount)
		return true
	if mountain_locations.has(hit_location):
		return true
	return false

func check_for_push(hit_location:Vector2):
	#Push characters around a hit_location
	print(hit_location) 
	var surrounding_locations = add_surrounding_location_to_array(hit_location)
	for location in surrounding_locations:
		var push_direction = location - hit_location
		if is_location_in_players(location):
			var player = get_player_at_location(location)
			player.get_pushed(push_direction)
		if is_location_in_enemies(location):
			var enemy = get_enemy_at_location(location)
			if is_instance_valid(enemy):
				enemy.get_pushed(push_direction)


func check_for_push_damage_in_direction(hit_location:Vector2,direction:Vector2, damage:int):
	#Push and damage characters in a known direction.
	if is_location_in_players(hit_location):
		var player = get_player_at_location(hit_location)
		player.get_pushed(direction)
		player.take_damage(damage)
	if is_location_in_enemies(hit_location):
		var enemy = get_enemy_at_location(hit_location)
		enemy.take_damage(damage)
		enemy.get_pushed(direction)

func check_for_push_in_direction(hit_location:Vector2,direction:Vector2):
	#Push characters in a known direction.
	if is_location_in_players(hit_location):
		var player = get_player_at_location(hit_location)
		player.get_pushed(direction)
	if is_location_in_enemies(hit_location):
		var enemy = get_enemy_at_location(hit_location)
		enemy.get_pushed(direction)

func add_surrounding_location_to_array(hit_location:Vector2) -> Array:
	#Add surrounding locations to an array for checking.
	var locations_to_check = []
	locations_to_check.append(hit_location + Vector2.UP)
	locations_to_check.append(hit_location + Vector2.RIGHT)
	locations_to_check.append(hit_location + Vector2.DOWN)
	locations_to_check.append(hit_location + Vector2.LEFT)
	return locations_to_check

func is_location_in_players(location:Vector2)->bool:
	#See if a player character is standing on the location.
	var player_positions = player_locations.values()
	if player_positions.has(location):
		return true
	return false

func is_location_in_enemies(location:Vector2)->bool:
	#See if a player character is standing on the location.
	var enemies_positions = enemy_locations.values()
	if enemies_positions.has(location):
		return true
	return false

func get_player_at_location(location:Vector2) -> player_character:
	#Get the player standing at the location
	for player in player_locations:
		if player_locations[player] == location:
			return player
	return null

func get_enemy_at_location(location:Vector2):
	#Get enemy at the location
	for enemy in enemy_locations:
		if enemy_locations[enemy] == location:
			return enemy

func set_walkable_tiles(value):
	walkable_tiles = value

func get_active_player() ->player_character:
	#Return a player that is currently active
	for player in player_locations:
		if player.active_player:
			return player
	return null

func count_moved_players()-> int:
	#Count how many players have moved this turn.
	var num_of_moved:int = 0
	for player in player_locations:
		if player.has_moved:
			num_of_moved += 1
	return num_of_moved

func change_active_player(new_active_player_loc:Vector2)->player_character:
	for player in player_locations:
		player.active_player = false
		if player_locations[player] == new_active_player_loc:
			player.active_player = true
	return get_active_player()

func reset_players_move_and_attack():
	for player in player_locations:
		player.has_attacked = false
		player.has_moved = false

func is_location_a_building(test_location:Vector2) -> bool:
	#Check if a test location has a building on it.
	print("this got tested")
	return map_info.has(test_location)
	
func building_got_damaged():
	emit_signal("update_building_health",1)

func occupied_locations()->Array:
	var occupied_location = []
	occupied_location.append_array(player_locations.values())
	occupied_location.append_array(enemy_locations.values())
	return occupied_location

func reset_all_info():
	map_info.clear()
	walkable_tiles.clear()
	player_locations.clear()
	enemy_locations.clear()
	mountain_locations.clear()
