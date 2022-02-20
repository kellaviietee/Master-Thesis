extends TextureButton



func _on_To_Game_button_up():
	print("this works")
	get_tree().change_scene("res://Scenes/Main.tscn")
