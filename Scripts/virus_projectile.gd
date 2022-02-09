extends Node2D
signal shooting_done
onready var tween = get_node("Tween")

func move_to_target(start_pos,end_pos,end_map_loc, degrees):
	connect("shooting_done",get_parent().get_parent(),"shot_hit")
	rotation_degrees = degrees
	tween.interpolate_property(self,"position",start_pos,end_pos,1.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_all_completed")
	do_damage(end_map_loc)

func do_damage(end_map_pos):
	var players = get_tree().get_nodes_in_group("Players")
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var buildings = get_parent().buildings
	var mountains = get_parent().mountains
	var type
	for player in players:
		if get_parent().world_to_map(player.position) == end_map_pos:
			print("Player damaged")
			type = "player"
	for enemy in enemies:
		if get_parent().world_to_map(enemy.position) == end_map_pos:
			enemy.take_damage(1)
	for building in buildings:
		if building == end_map_pos:
			type = "building"
	for mountain in mountains:
		if mountain == end_map_pos:
			type = "mountain"
	emit_signal("shooting_done",end_map_pos,type)
	queue_free()
