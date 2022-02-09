extends TileMap
class_name characters_map

signal state_changed
signal character_finished
signal update_danger_tiles
signal character_died

enum STATES{spawning, enemy_movement, player_movement, player_attack, enemy_attack, no_click}

var current_state
var danger_tile_locs = []


export(PackedScene) var player
export(PackedScene) var melee_enemy
export(PackedScene) var ranged_enemy
export(PackedScene) var ranged_projectile

export(Resource) var map_info_resource
onready var houses_node = get_parent().get_node("Houses")
func _ready():
	current_state = STATES.spawning

func _input(event):
	#What happens when a mouse click is done
	if Input.is_action_just_released("click") and current_state == STATES.spawning:
		var click_location = check_where_on_map_was_clicked(get_global_mouse_position())
		if click_location != Vector2(100,100) and not map_info_resource.is_location_in_players(click_location):
			check_player_spawn(click_location)
			var player_count = count_player_characters()
			if player_count == 3:
				spawn_enemies(3)
				current_state = STATES.enemy_movement
				emit_signal("state_changed", STATES.enemy_movement)
	elif Input.is_action_just_released("click") and current_state == STATES.player_movement:
		var click_location = check_where_on_map_was_clicked(get_global_mouse_position())
		var active_player = map_info_resource.get_active_player()
		if active_player and not map_info_resource.is_location_in_players(click_location) and not active_player.has_moved: 
			if click_location != Vector2(100,100) and not map_info_resource.is_location_in_enemies(click_location):
				move_a_player_character(active_player)
		elif map_info_resource.is_location_in_players(click_location):
			 map_info_resource.change_active_player(click_location)
	else:
		return


func move_a_player_character(active_player:player_character):
	#Move a player character.
	if find_path_length(active_player,world_to_map(get_global_mouse_position())) <= 5:
		var player_path = find_character_path(active_player, world_to_map(get_global_mouse_position()))
		active_player.move_on_path(player_path)
		yield(active_player,"movement_done")
		active_player.has_moved = true

func  check_where_on_map_was_clicked(click_location: Vector2) -> Vector2:
	# See if player clicked on a map and return in what cell it was in
	var map_click_coord = world_to_map(click_location)
	var map_boundaries = get_used_cells()
	if map_click_coord in map_boundaries:
		return map_click_coord
	else:
		return Vector2(100,100)

func spawn_character(location:Vector2, character:Characters):
	#Spawn a character onto the map.
	add_child(character)
	character.position = map_to_world(location) + Vector2(0,32)
	update_character_location_to_info(character, location)
	var location_id = houses_node.convert_vector2_to_id(location)
	houses_node.astar.set_point_disabled(location_id, true)
	if character.is_in_group("player"):
		character.player_skin = count_player_characters() - 1
		map_info_resource.player_locations[character] = location

func find_character_path(character:Characters, end_pos:Vector2) -> PoolVector2Array:
	# Finds a path to move from point A to point B
	var character_pos_id = houses_node.convert_vector2_to_id(world_to_map(character.position))
	var end_pos_id = houses_node.convert_vector2_to_id(end_pos)
	var path = houses_node.get_vector_paths(character_pos_id, end_pos_id)
	houses_node.update_astar_walkable_tiles(character_pos_id, end_pos_id)
	update_character_location_to_info(character, end_pos)
	return path

func update_character_location_to_info(character:Characters, current_pos: Vector2):
	# Add info where characters are to databases.
	var all_players = get_tree().get_nodes_in_group("player")
	if character in all_players:
		map_info_resource.player_locations[character] = current_pos
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	if character in all_enemies:
		map_info_resource.enemy_locations[character] = current_pos

func shoot_ranged_projectile(start_pos:Vector2, end_pos:Vector2):
	#Create a projectile to shoot at a target.
	var local_map_position = world_to_map(start_pos)
	var direction:Vector2 = (end_pos - local_map_position).normalized()
	var world_direction = map_to_world(direction)
	var new_projectile:ranged_projectile = ranged_projectile.instance()
	add_child(new_projectile)
	new_projectile.position = start_pos + world_direction + Vector2(0,32)
	new_projectile.direction = direction
	new_projectile.move_and_check()
	yield(new_projectile,"shot_ended")
	yield(get_tree(),"idle_frame")
	emit_signal("character_finished")

func count_player_characters()->int:
	#Count how many player characters there are.
	var all_players = get_tree().get_nodes_in_group("player")
	return all_players.size()


func find_path_length(character:Characters, end_pos:Vector2) -> int:
	# Finds a path to move from point A to point B
	var character_pos_id = houses_node.convert_vector2_to_id(world_to_map(character.position))
	var end_pos_id = houses_node.convert_vector2_to_id(end_pos)
	var path:PoolVector2Array = houses_node.get_vector_paths(character_pos_id, end_pos_id)
	return path.size()

func add_dangerous_tiles(dangerous_locations:Array):
	danger_tile_locs.append_array(dangerous_locations)
	emit_signal("update_danger_tiles",danger_tile_locs)
	

func remove_dangerous_tiles(dangerous_locations:Array):
	for location in dangerous_locations:
		if danger_tile_locs.has(location):
			danger_tile_locs.erase(location)
	emit_signal("update_danger_tiles",danger_tile_locs)

func update_all_characters_info():
	# Add info where characters are to databases.
	var all_players = get_tree().get_nodes_in_group("player")
	for player in all_players:
		map_info_resource.player_locations[player] = world_to_map(player.position)
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		map_info_resource.enemy_locations[enemy] = world_to_map(enemy.position)

func check_player_spawn(spawn_location:Vector2):
	if spawn_location in map_info_resource.walkable_tiles and not spawn_location.x > 3:
		spawn_character(spawn_location, player.instance())
	
func spawn_enemies(how_many:int):
	#Spawn enemies on the map
	var all_free_locs:Array = map_info_resource.walkable_tiles
	var free_lower_part_of_map:Array = lower_half_of_map(all_free_locs)
	for _i in range(how_many):
		randomize()
		var random_int = randi() % free_lower_part_of_map.size()
		var random_location = free_lower_part_of_map[random_int]
		spawn_character(random_location, ranged_enemy.instance())

func lower_half_of_map(all_free_locations:Array)->Array:
	var lower_part_of_map:Array = []
	for location in all_free_locations:
		if location.x >= 4 and not map_info_resource.is_location_in_players(location) and not map_info_resource.is_location_in_enemies(location):
			lower_part_of_map.append(location)
	return lower_part_of_map

func character_death(character_position:Vector2):
	emit_signal("character_died",world_to_map(character_position))
