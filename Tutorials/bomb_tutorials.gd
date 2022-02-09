extends Node2D

onready var anim = $AnimationPlayer

func _ready():
	anim.play("direct_hit")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "direct_hit":
		anim.play("next_to")
	else:
		anim.play("direct_hit")
