extends TextureRect

func _on_Level1_update_turn(turns_left:int):
	get_node("Counter").text = tr("ROUND_COUNT") % str(turns_left)
