extends Sprite

onready var billboard = get_node("billboard text")

func _on_Floor_state_changed(new_state):
	match new_state:
		0: billboard.text = tr("BILL1")
		1: billboard.text = tr("BILL2")
		2: billboard.text = tr("BILL3")
		4: billboard.text = tr("BILL4")
