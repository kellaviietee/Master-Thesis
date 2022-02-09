extends bomb

func _on_Tween_tween_completed(_object, key):
	if key == ":unit_offset":
		map_info.check_for_damage(target_map_location, 2)
		queue_free()
