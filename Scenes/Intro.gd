extends Control

func _ready():
	get_node("to_game/to_Game_label").text = tr("INTRO")
	get_node("game_goal").text = tr("GAME_GOAL")
	get_node("game_goal_desc").text = tr("GAME_GOALS")
	get_node("game_turns_desc").text = tr("GAME_TURN_DESC")
	get_node("game_turns").text = tr("GAME_TURN")
	get_node("player_turn_desc").text = tr("PLAYER_TURN_DESC")
	get_node("player_turn").text = tr("PLAYER_TURN")
	get_node("character_desc").text = tr("CHARACTERS_DESC")
	get_node("About characters").text = tr("CHARACTERS")
	get_node("game_instructions").text = tr("INSTRUCTION")


func _on_to_game_button_up():
		get_tree().change_scene("res://Scenes/Main.tscn")
