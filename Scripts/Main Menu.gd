extends Control

onready var new_text = get_node("New Game/New_game_text")
onready var about_text = get_node("About/About_text")
onready var exit_text = get_node("Exit Game/Exit_text")

func _ready():
	update_texts()

func _on_Exit_Game_button_up():
	get_tree().quit()

func _on_New_Game_button_up():
	get_tree().change_scene("res://Scenes/Intro.tscn")


func _on_About_button_up():
	pass # Replace with function body.


func _on_English_button_up():
	TranslationServer.set_locale("en")
	update_texts()


func _on_Estonian_button_up():
	TranslationServer.set_locale("et")
	update_texts()

func update_texts():
	new_text.text = tr("START")
	about_text.text = tr("INFO")
	exit_text.text = tr("QUIT")
