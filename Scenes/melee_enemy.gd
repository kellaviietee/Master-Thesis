extends Characters
class_name melee_enemy
var movement_end_pos: Vector2
var possible_walking_positions: PoolVector2Array

func find_position():
	for player in map_info.player_locations:
		var player_location = map_info.player_locations[player]
		target = player_location
		possible_walking_positions = map_info.available_position_next_to_location(player_location)
	randomize()
	var pick_a_pos = randi() % possible_walking_positions.size()
	movement_end_pos = possible_walking_positions[pick_a_pos]

func attack_the_target():
	map_info.check_for_damage(target)
	


