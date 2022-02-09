extends Area2D

onready var tween = get_node("Tween")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func move(startpos, vector,_target_on_map):
	tween.interpolate_property(self,"position",startpos,startpos + vector,1.0,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_all_completed")
	hit_enemy(startpos + vector)
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.


func hit_enemy(target):
	var Enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in Enemies:
		if enemy.position == target:
			enemy.take_damage(1)


