extends TileMap


var astar = AStar2D.new()
export(Resource) var initial_map_info
var walkable_tiles = []
var dangerous_locs:Array = []
export(Texture) var danger_tiles

signal new_round

func _ready():
	put_map_info_to_resource()
	update_walkable_tiles()
	

func put_map_info_to_resource():
# save map_info_to_a_resource.
	var all_tile_dict = {}
	var all_tiles = get_used_cells()
	for tile in all_tiles:
		if get_cellv(tile) == 0 or get_cellv(tile) == 1 or get_cellv(tile) == 2:
			all_tile_dict[tile] = get_cellv(tile)
		if get_cellv(tile) == 3:
			initial_map_info.mountain_locations.append(tile)
	initial_map_info.map_info = all_tile_dict

func update_walkable_tiles():
	# Update walkable_tiles
	walkable_tiles = find_all_walkable_tiles()
	initial_map_info.walkable_tiles = walkable_tiles
	update_astar_map()

func update_astar_map():
	#Updates the astar map of which the characters can move on.
	astar.clear()
	for tile in walkable_tiles:
		astar.add_point(convert_vector2_to_id(tile),map_to_world(tile))
	for tile in walkable_tiles:
		connect_astar_tiles(tile)
	var occupied_tiles = initial_map_info.occupied_locations()
	for tile in occupied_tiles:
		astar.set_point_disabled(convert_vector2_to_id(tile))


func connect_astar_tiles(tile):
	#Connect all the astar points  to each other.
	if walkable_tiles.has(tile + Vector2.UP) and not astar.are_points_connected(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.UP)):
		astar.connect_points(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.UP))
	if walkable_tiles.has(tile + Vector2.RIGHT) and not astar.are_points_connected(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.RIGHT)):
		astar.connect_points(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.RIGHT))
	if walkable_tiles.has(tile + Vector2.DOWN) and not astar.are_points_connected(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.DOWN)):
		astar.connect_points(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.DOWN))
	if walkable_tiles.has(tile + Vector2.LEFT) and not astar.are_points_connected(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.LEFT)):
		astar.connect_points(convert_vector2_to_id(tile), convert_vector2_to_id(tile + Vector2.UP))

func find_all_walkable_tiles() -> Array:
	#Find all tiles a character can walk on.
	var used_cells = get_used_cells()
	var temp_array = []
	for i in 8:
		for j in 8:
			if not used_cells.has(Vector2(i,j)):
				temp_array.append(Vector2(i,j))
	return temp_array

func update_astar_walkable_tiles(start_id:int, end_id:int):
	#Updates a walkable astar map
	astar.set_point_disabled(start_id, false)
	astar.set_point_disabled(end_id, true)

func convert_vector2_to_id(vector_to_convert:Vector2) -> int:
	#Convert Vector2 position to an astar id.
	var id = vector_to_convert.x + vector_to_convert.y * 8
	return id

func get_vector_paths(start_pos_id, end_pos_id):
	# Returns Vector2 location that make up the path of a character.
	if astar.has_point(start_pos_id) and astar.has_point(end_pos_id):
		return astar.get_point_path(start_pos_id, end_pos_id)
	else:
		
		return []

func _draw():
	for location in dangerous_locs:
		draw_texture(danger_tiles,map_to_world(location + Vector2.LEFT) + Vector2(0,64)) 


func _on_Floor_update_danger_tiles(new_danger_tiles:Array):
	#Update visual locations of enemy aiming.
	dangerous_locs = new_danger_tiles
	update()




func _on_Floor_character_died(death_location:Vector2):
	#If a character died, release the location for astar pathfinding.
	var death_location_id = convert_vector2_to_id(death_location)
	astar.set_point_disabled(death_location_id,false)
	update_walkable_tiles()


func _on_Level1_new_map():
	Global.round_number += 1
	dangerous_locs.clear()
	update()
	initial_map_info.map_info.clear()
	initial_map_info.walkable_tiles.clear()
	initial_map_info.player_locations.clear()
	initial_map_info.enemy_locations.clear()
	clear()
	if Global.round_number == 2:
		var new_house_locations:Array = Global.level2
		for id in new_house_locations.size():
			var location = convert_id_to_vector2(id)
			var building = new_house_locations[id]
			set_cellv(location,building)
	elif Global.round_number == 3:
		var new_house_locations:Array = Global.level3
		for id in new_house_locations.size():
			var location = convert_id_to_vector2(id)
			var building = new_house_locations[id]
			set_cellv(location,building)
	elif Global.round_number >= 4:
		get_tree().change_scene("res://Scenes/Win Screen.tscn")
		return
	put_map_info_to_resource()
	update_walkable_tiles()
	emit_signal("new_round")
	

func convert_id_to_vector2(id:int):
	var y:int = id / 8
	var x: int = id % 8
	return Vector2(x,y)
	
	
