extends Characters
class_name player_character
onready var anim = $AnimationPlayer

var has_moved:bool = false
var has_attacked:bool = false
var active_player:bool = false setget set_active_player

var player_skin:int = 0 setget set_player_skin

func set_player_skin(skin_id:int)-> void:
	$AnimatedSprite.frame = skin_id

func teleport_out():
	#Teleport disapear
	$AnimationPlayer.play("teleport_dissappear")

func teleport_in():
	#Teleport appear
	$AnimationPlayer.play("teleport_appear")

func _draw():
	pass

func _on_healthbar_death():
	print("character died")

func set_active_player(new_value):
	if new_value == false:
		$AnimationPlayer.stop(true)
		$Arrow.visible = false
		active_player = false
	else:
		$AnimationPlayer.play("Active player")
		active_player = true
