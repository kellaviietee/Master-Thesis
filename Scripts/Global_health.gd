extends TextureProgress



func _on_BuildingHealth_health_changed(new_value):
	value = new_value
	if value <= 0:
		print("Game Over")
