extends Node2D

onready var character_map = get_node("Floor")
onready var house_map = get_node("Houses")
onready var tween = get_node("Tween")

signal remove_attack
signal reset_attacks
signal ability_done
signal update_turn
signal new_map

var ability_counter = 0

export  var map_info_resource:Resource
export(PackedScene) var bomb
export(PackedScene) var water_bomb
export(PackedScene) var pulling_rod
export(PackedScene) var pushing_rod

var turns_left = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("update_turn", turns_left)

func _on_End_Turn_button_up():
	#What happens when End Turn is pressed
	get_node("End_Turn").disabled = true
	character_map.current_state = character_map.STATES.enemy_attack
	character_map.emit_signal("state_changed",character_map.current_state)
	emit_signal("ability_done",2)
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in all_enemies:
		if is_instance_valid(enemy):
			enemy.attack_the_target()
			yield(character_map,"character_finished")
		else:
			continue
	yield(get_tree(),"idle_frame")
	map_info_resource.reset_players_move_and_attack()
	emit_signal("reset_attacks")
	turns_left -= 1
	if turns_left <= 0:
		character_map.current_state = character_map.STATES.no_click
		exit_scene()
		turns_left = 4
		emit_signal("update_turn", turns_left)
		ability_counter = 0
		return
	emit_signal("update_turn",turns_left)
	character_map.spawn_enemies(2)
	ability_counter = 0
	character_map.emit_signal("state_changed",1)


func _on_Attack_button_up():
	var attack_being_used = get_node("Abilities").current_ability
	var target = get_node("Abilities").target
	match attack_being_used:
		0: pull_a_character(target)
		1: teleport_player(target)
		2: attack_with_a_bomb()
		3: attack_with_a_water_bomb(target)
		4: push_a_character(target)
		5: punch_a_character(target)
		6: return
	emit_signal("ability_done",ability_counter)
	ability_counter += 1
	

func punch_a_character(target:Vector2):
	#Punch a character for 2 hit points if next to it using vector scalars.
	var generated_vector = get_node("Abilities").gen_vec
	var scalar_value = target.dot(generated_vector)
	var player_scale = get_node("Abilities").scalar_value
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	var player_map_position = character_map.world_to_map(player.position)
	var locations_around_target:Array = map_info_resource.add_surrounding_location_to_array(target)
	if locations_around_target.has(player_map_position) and player_scale == scalar_value and not player.has_attacked:
		map_info_resource.check_for_push_damage_in_direction(target,target - player_map_position, 2)
		player.has_attacked = true
		player.active_player = false
	elif not player.has_attacked:
		map_info_resource.check_for_push_in_direction(player_map_position,player_map_position - target)
		player.has_attacked = true
		player.active_player = false
	emit_signal("remove_attack",5)
	
	

func teleport_player(target:Vector2):
	#Teleport a player to a target location
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	var available_locations:Array = map_info_resource.walkable_tiles
	player.teleport_out()
	yield(player.anim,"animation_finished")
	if available_locations.has(target) and not map_info_resource.is_location_in_players(target) and not map_info_resource.is_location_in_enemies(target) and not player.has_attacked:
		player.position = character_map.map_to_world(target) + Vector2(0,32)
		player.has_attacked = true
		player.active_player = false
		map_info_resource.player_locations[player] = target
	else:
		player.has_attacked = true
		player.active_player = false
		print("can't teleport there.")
	player.teleport_in()
	emit_signal("remove_attack",1)
	yield(player.anim,"animation_finished")
	

func push_a_character(target_location:Vector2):
	#Push a character in a target location.
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	player.target = target_location
	var generated_vector = get_node("Abilities").gen_vec
	var answer_vector = get_node("Abilities").answer_vec
	var player_map_position = character_map.world_to_map(player.position)
	if player_map_position.x == player.target.x or player_map_position.y == player.target.y and not player.has_attacked:
		if(target_location + generated_vector == answer_vector):
			var direction:Vector2 = -(player_map_position - player.target).normalized()
			var new_rod = pushing_rod.instance()
			new_rod.position = character_map.map_to_world(player_map_position + direction) + Vector2(0,32)
			new_rod.rotation = character_map.map_to_world(target_location).angle_to_point(player.position)
			new_rod.direction = direction
			character_map.add_child(new_rod)
			new_rod.move_and_check()
		elif(target_location + generated_vector != answer_vector):
			pass
		player.has_attacked = true
		player.active_player = false
	emit_signal("remove_attack",4)

func pull_a_character(pulling_from:Vector2):
	#Pull a character to a desired direction.
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	player.target = pulling_from
	var generated_vector = get_node("Abilities").gen_vec
	var answer_vector = get_node("Abilities").answer_vec
	var player_map_position = character_map.world_to_map(player.position)
	if player_map_position.x == player.target.x or player_map_position.y == player.target.y and not player.has_attacked:
		if(pulling_from - generated_vector == answer_vector):
			print("correct answer")
			var direction:Vector2 = -(player_map_position - player.target).normalized()
			var new_rod = pulling_rod.instance()
			new_rod.position = character_map.map_to_world(player_map_position + direction) + Vector2(0,32)
			new_rod.rotation = character_map.map_to_world(pulling_from).angle_to_point(player.position)
			new_rod.direction = direction
			character_map.add_child(new_rod)
			new_rod.move_and_check()
		elif(pulling_from - generated_vector != answer_vector):
			pass
		player.has_attacked = true
		player.active_player = false
	emit_signal("remove_attack",0)

func attack_with_a_water_bomb(math_target:Vector2):
	#Throw a waterbomb toward a target.
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	var player_map_position = character_map.world_to_map(player.position)
	var player_answer = get_node("Abilities").magnitude
	var right_answer = math_target.distance_squared_to(player_map_position)
	if player_answer == right_answer and not player.has_attacked:
		var new_water_bomb = water_bomb.instance()
		add_child(new_water_bomb)
		var target = math_target
		var target_world_coord = character_map.map_to_world(target)
		new_water_bomb.start(player.position, target_world_coord, target)
		player.has_attacked = true
		player.active_player = false
	emit_signal("remove_attack",3)

func attack_with_a_bomb():
	#Throw a bomb.
	var new_bomb = bomb.instance()
	add_child(new_bomb)
	var player:player_character = map_info_resource.get_active_player()
	if player == null:
		return
	var target = get_node("Abilities").target + character_map.world_to_map(player.position)
	var target_world_coord = character_map.map_to_world(target)
	if not player.has_attacked:
		new_bomb.start(player.position, target_world_coord, target)
		player.has_attacked = true
		player.active_player = false
	emit_signal("remove_attack",2)

func _on_Floor_state_changed(new_state):
	#Change a state of the game
	match new_state:
		1:	
			var all_enemies = get_tree().get_nodes_in_group("enemies")
			for enemy in all_enemies:
				enemy.find_position()
				yield(get_tree().create_timer(0.5),"timeout")
				var enemy_path = character_map.find_character_path(enemy, enemy.movement_end_pos)
				enemy.move_on_path(enemy_path)
				yield(enemy,"movement_done")
			character_map.current_state = character_map.STATES.player_movement
			character_map.emit_signal("state_changed",character_map.current_state)
			get_node("End_Turn").disabled = false

func exit_scene():
	var initial_location:Vector2 = house_map.position
	get_tree().call_group("character","end_of_round")
	tween.interpolate_property(house_map,"position",position,position + Vector2(0, -1500),2.0,Tween.TRANS_QUART,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	map_info_resource.reset_all_info()
	emit_signal("new_map")
	tween.interpolate_property(house_map,"position",position,initial_location,2.0,Tween.TRANS_QUART,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	character_map.current_state = character_map.STATES.spawning
	character_map.emit_signal("state_changed",character_map.current_state)
