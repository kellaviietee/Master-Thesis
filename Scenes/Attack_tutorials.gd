extends Node2D

onready var attack_tutorials:Array = get_children()

func _on_Abilities_activate_ability(ability:int):
	for tutorial in attack_tutorials:
		tutorial.visible = false
	if ability < get_child_count():
		get_child(ability).visible = true

