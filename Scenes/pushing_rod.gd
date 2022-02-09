extends Node2D
class_name pushing_rod
var direction:Vector2
export(Resource) var map_info

func move_and_check():
	#Move the pulling rod and see if it hit the target.
	var current_location = get_parent().world_to_map(position)
	if map_info.is_location_in_players(current_location):
		map_info.check_for_push_in_direction(current_location, direction)
		$Tween.interpolate_property(self,"position",position, position + get_parent().map_to_world(direction),1.0,Tween.TRANS_LINEAR,Tween.EASE_IN,1.0)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		queue_free()
	elif map_info.is_location_in_enemies(current_location):
		map_info.check_for_push_in_direction(current_location, direction)
		$Tween.interpolate_property(self,"position",position, position + get_parent().map_to_world(direction),1.0,Tween.TRANS_LINEAR,Tween.EASE_IN,1.0)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		queue_free()
	else:
		$Tween.interpolate_property(self,"position",position, position + get_parent().map_to_world(direction),1.0,Tween.TRANS_LINEAR,Tween.EASE_IN)
		$Tween.start()
		yield($Tween,"tween_all_completed")
		move_and_check()
		
