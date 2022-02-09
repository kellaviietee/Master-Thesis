extends KinematicBody2D
class_name Characters

onready var health = $health/healthbar
onready var tween = $Tween
export(Resource) var map_info
signal movement_done
signal took_damage
var target:Vector2 setget set_target



func move_on_path(path: PoolVector2Array):
	var current_state = get_parent().current_state
	get_parent().current_state = get_parent().STATES.no_click
	#Move along a path
	for step in path:
		tween.interpolate_property(self, "position", position, step + Vector2(0, 32), 1.0, Tween.TRANS_LINEAR,Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_completed")
	emit_signal("movement_done")
	get_parent().current_state = current_state
	update()

func _draw():
	pass
	#draw_line(to_local(position), to_local(get_parent().map_to_world(target) + Vector2(0,32)),Color.azure,5.0)

func take_damage(damage:int):
	#Take damage from something.
	emit_signal("took_damage", damage)

func set_target(new_target:Vector2):
	target = new_target
	update()

func get_pushed(direction:Vector2):
	#Character gets pushed in a direction
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
	elif not map_info.walkable_tiles.has(end_location):
		take_damage(1)

func end_of_round():
	tween.interpolate_property(self,"position",position,position + Vector2(0, -1500),2.0,Tween.TRANS_QUART,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	queue_free()
	
