extends TileMap

signal enemy_target_acquired
var enemy_targets = []
var enemy_position = []



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#Send all the enemy aiming to here
func _draw():
	if enemy_targets.size() != 0 && enemy_position.size() != 0:
		for i in enemy_targets.size():
			draw_line(map_to_world(enemy_targets[i])+Vector2(0,64),map_to_world(enemy_position[i])+Vector2(0,64),Color( 0.41, 0.41, 0.41, 1 ),16.0)
	else: draw_line(map_to_world(Vector2(0,0)),map_to_world(Vector2(0,0)),Color( 0.41, 0.41, 0.41, 1 ),16.0)

func add_aiming():
	enemy_targets.clear()
	enemy_position.clear()
	var all_enemies = get_tree().get_nodes_in_group("Enemies")
	for i in all_enemies.size():
		enemy_position.append(all_enemies[i].shooting_pos)
		enemy_targets.append(all_enemies[i].target + all_enemies[i].shooting_pos)
		emit_signal("enemy_target_acquired")
		update()

func no_target():
	emit_signal("enemy_target_acquired")
	pass
