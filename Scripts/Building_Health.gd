extends Node2D

export(Resource) var map_info

signal health_changed
var health = Global.building_health

# Called when the node enters the scene tree for the first time.
func _ready():
	map_info.connect("update_building_health", self,"update_health")
	emit_signal("health_changed",Global.building_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update_health(damage):
	health -= damage
	if health <=0:
		get_tree().change_scene("res://Scenes/Lost Screen.tscn")
	emit_signal("health_changed",health)
