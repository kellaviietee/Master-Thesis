extends Area2D
class_name ranged_projectile

signal shot_ended

var current_map_pos:Vector2
var direction:Vector2
export(Resource) var map_info

func move_and_check():
	var current_location = get_parent().world_to_map(position)
	if map_info.check_for_damage(current_location):
		yield(get_tree(),"idle_frame")
		emit_signal("shot_ended")
		queue_free()
	elif current_location.x >= 7 or current_location.x <= 0 or current_location.y >= 7 or current_location.y <= 0:
		yield(get_tree(),"idle_frame")
		emit_signal("shot_ended")
		queue_free()
	else:
		$Tween.interpolate_property(self,"position",position,position + get_parent().map_to_world(direction),2.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween,"tween_completed")
		move_and_check()



