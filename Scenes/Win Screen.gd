extends Control



func _ready():
	get_node("Label").text = tr("WIN")
	get_node("TextureButton/Label").text = tr("MAIN_MENU")
	Global.player_character_nr = 3
	Global. building_health = 7


func _on_TextureButton_button_up():
	get_tree().change_scene("res://Scenes/Main Menu.tscn")
