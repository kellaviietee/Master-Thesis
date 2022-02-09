extends Area2D

onready var tween = get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move(startpos, endpos, midpoint,target_on_map):
	get_node("Sprite").rotation_degrees = rad2deg(get_node("Sprite").get_angle_to(midpoint) + PI/2)
	tween.interpolate_property(self,"position:y",startpos.y,midpoint.y - 50,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.interpolate_property(self,"position:x",startpos.x,midpoint.x,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	yield(tween,"tween_completed")
	get_node("Sprite").rotation_degrees = rad2deg(get_node("Sprite").get_angle_to(endpos) + PI/2)
	tween.interpolate_property(self,"position:y",midpoint.y - 50,endpos.y,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(self,"position:x",midpoint.x,endpos.x,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	yield(tween,"tween_completed")
	hit_enemy(target_on_map)
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func hit_enemy(target):
	var enemy = get_parent().check_enemy_locations()
	if enemy.has(target):
		var enemy_index = enemy.find(target)
		var all_enemies = get_tree().get_nodes_in_group("Enemies")
		var target_enemy = all_enemies[enemy_index]
		target_enemy.take_damage(1)
