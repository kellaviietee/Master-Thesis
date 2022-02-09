extends Sprite
signal update_target
var starting_x = 0
var starting_y = 0

	
	

func _on_X_up_input_event(_viewport, event, _shape_idx):
	starting_x = int(get_node("Xcoord").text)
	if event.is_action_released("click"):
		starting_x = wrapi(starting_x + 1,-7,8)
		get_node("Xcoord").text = str(starting_x)
		emit_signal("update_target",Vector2(starting_x,starting_y))

func _on_X_down_input_event(_viewport, event, _shape_idx):
	starting_x = int(get_node("Xcoord").text)
	if event.is_action_released("click"):
		starting_x = wrapi(starting_x - 1,-7,8)
		get_node("Xcoord").text = str(starting_x)
		emit_signal("update_target",Vector2(starting_x,starting_y))


func _on_Y_up_input_event(_viewport, event, _shape_idx):
	starting_y = int(get_node("Ycoord").text)
	if event.is_action_released("click"):
		starting_y = wrapi(starting_y + 1,-7,8)
		get_node("Ycoord").text = str(starting_y)
		emit_signal("update_target",Vector2(starting_x,starting_y))


func _on_Y_down_input_event(_viewport, event, _shape_idx):
	starting_y = int(get_node("Ycoord").text)
	if event.is_action_released("click"):
		starting_y = wrapi(starting_y - 1,-7,8)
		get_node("Ycoord").text = str(starting_y)
		emit_signal("update_target",Vector2(starting_x,starting_y))
