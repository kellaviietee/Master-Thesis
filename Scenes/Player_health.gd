extends ProgressBar



func _on_Player_get_hit(damage):
	value -= damage
