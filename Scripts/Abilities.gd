extends Node2D
var current_ability
onready var main = get_parent()
onready var game_floor = main.get_node("Floor")
onready var tween = get_node("Tween")
signal activate_ability
signal random_vector
signal start_of_round
var target = Vector2()
var gen_vec = Vector2()
var magnitude:int
var scalar_value:int
onready var buttons = [get_node("Nerfgun"), get_node("Soap"), get_node("Water"),get_node("Vaccine"), get_node("Sleep"), get_node("Stinkbomb")]
func _ready():
	set_button_texts()

func _input(_event):
	if Input.is_action_just_released("click") && game_floor.current_state == game_floor.STATES.player_movement: 
		var test_target = game_floor.world_to_map(get_global_mouse_position())
		if test_target.x > -1 and test_target.y > -1 and test_target.x < 8 and test_target.y < 8:
			target = test_target
			var player:player_character = get_tree().get_nodes_in_group("player")[0]
			player.target = target
			match current_ability:
				0: vector_addition(target)
				3: get_node("Magnitude/answer_box/Target").text = str(target)
				4: vector_addition(target)
				5: vector_addition(target)


func vector_addition(target):
	match current_ability:
		4:
			get_node("Vector addition/Target").text = str(target)
			randomize()
			var generator = RandomNumberGenerator.new()
			generator.randomize()
			var x = generator.randi_range(-7,7)
			generator.randomize()
			var y = generator.randi_range(-7,7)
			var generated_vector = Vector2(x,y)
			emit_signal("random_vector",generated_vector)
			get_node("Vector addition/generated_vector").text = str(generated_vector)
		0:
			get_node("Vector subtraction/Target").text = str(target)
			randomize()
			var generator = RandomNumberGenerator.new()
			generator.randomize()
			var x = generator.randi_range(-7,7)
			generator.randomize()
			var y = generator.randi_range(-7,7)
			var generated_vector = Vector2(x,y)
			emit_signal("random_vector",generated_vector)
			get_node("Vector subtraction/generated_vector").text = str(generated_vector)
		5:
			get_node("Vector dot product/Target").text = str(target)
			randomize()
			var generator = RandomNumberGenerator.new()
			generator.randomize()
			var x = generator.randi_range(-7,7)
			generator.randomize()
			var y = generator.randi_range(-7,7)
			var generated_vector = Vector2(x,y)
			gen_vec = generated_vector
			emit_signal("random_vector",generated_vector)
			get_node("Vector dot product/generated_vector").text = str(generated_vector)

func _on_Stickyhand_button_up():
	current_ability = 0
	change_UI(0)
	change_tutorial(0)
	emit_signal("activate_ability",current_ability)
	pass # Replace with function body.


func _on_Stinkbomb_button_up():
	#Teleporting ability button.
	current_ability = 1
	change_UI(1)
	change_tutorial(1)
	emit_signal("activate_ability",current_ability)


func _on_Soap_button_up():
	current_ability = 2
	change_UI(2)
	change_tutorial(2)
	emit_signal("activate_ability",current_ability)
	pass # Replace with function body.


func _on_Water_button_up():
	current_ability = 3
	emit_signal("activate_ability",current_ability)
	change_UI(3)
	change_tutorial(3)
	pass # Replace with function body.


func _on_Vaccine_button_up():
	current_ability = 4
	emit_signal("activate_ability",current_ability)
	change_UI(4)
	change_tutorial(4)
	pass # Replace with function body.

func _on_Sleep_button_up():
	current_ability = 5
	emit_signal("activate_ability",current_ability)
	change_UI(5)
	change_tutorial(5)
	pass

func change_UI(current_ability):
	var current_targeting_system 
	for targeting_system in get_tree().get_nodes_in_group("targeting_system"):
		if targeting_system.position == Vector2(-1100,770):
			current_targeting_system = targeting_system
	match current_ability:
		0:
			reset_vector_substraction()
			tween.interpolate_property(get_node("Vector subtraction"),"position",get_node("Vector subtraction").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Vector subtraction").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
		1,2:
			reset_coordinates()
			tween.interpolate_property(get_node("Coordinates"),"position",get_node("Coordinates").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Coordinates").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
		3:
			reset_magnitude()
			tween.interpolate_property(get_node("Magnitude"),"position",get_node("Magnitude").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Magnitude").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
		4:
			reset_vector_addition()
			tween.interpolate_property(get_node("Vector addition"),"position",get_node("Vector addition").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Vector addition").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
		5:
			reset_vector_dot_product()
			tween.interpolate_property(get_node("Vector dot product"),"position",get_node("Vector dot product").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Vector dot product").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
		6:
			tween.interpolate_property(get_node("Blank system"),"position",get_node("Blank system").position,current_targeting_system.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN)
			tween.interpolate_property(current_targeting_system,"position",current_targeting_system.position,get_node("Blank system").position,1.0,Tween.TRANS_BACK,Tween.EASE_OUT)
	tween.start()
	get_tree().set_group("Ability_buttons","disabled",true)
	yield(tween,"tween_all_completed")
	get_tree().set_group("Ability_buttons","disabled",false)

func change_tutorial(current_ability):
	var current_tutorial 
	for tutorial in get_tree().get_nodes_in_group("Tutorial"):
		if tutorial.position == Vector2(1150,140):
			current_tutorial = tutorial
	match current_ability:
		0:
			tween.interpolate_property(get_node("tut vector subtraction"),"position",get_node("tut vector subtraction").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("tut vector subtraction").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		1:
			tween.interpolate_property(get_node("position_vector"),"position",get_node("position_vector").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("position_vector").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		2:
			tween.interpolate_property(get_node("Vector tutorial"),"position",get_node("Vector tutorial").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("Vector tutorial").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		3:
			tween.interpolate_property(get_node("vector length"),"position",get_node("vector length").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("vector length").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		4:
			tween.interpolate_property(get_node("tut vector addition"),"position",get_node("tut vector addition").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("tut vector addition").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		5:
			tween.interpolate_property(get_node("dot tutorial"),"position",get_node("dot tutorial").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("dot tutorial").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()
		6:
			tween.interpolate_property(get_node("Blank Tutorial"),"position",get_node("Blank Tutorial").position,current_tutorial.position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.interpolate_property(current_tutorial,"position",current_tutorial.position,get_node("Blank Tutorial").position,1.0,Tween.TRANS_BACK,Tween.EASE_IN_OUT)
			tween.start()

func set_button_texts():
	get_node("dot tutorial/scal_tut_text").text = tr("SCAL_TUT")
	get_node("Vector tutorial/tutorial text box/vec_tut_text").text = tr("VEC_TUT")
	get_node("position_vector/tutorial text box2/vec_tut_text").text = tr("POS_TUT")
	get_node("vector length/tutorial text box3/vec_len_text").text = tr("LEN_TUT")
	get_node("tut vector addition/tutorial text box4/vec_add_text").text = tr("ADD_TUT")
	get_node("tut vector subtraction/tutorial text box5/vec_sub_text").text = tr("SUB_TUT")
	main.get_node("End_Turn/end turn text").text = tr("END")
	main.get_node("Attack/attack text").text = tr("ATTACK")
	main.get_node("chained_billboard/billboard text").text = tr("BILL1")
	emit_signal("start_of_round",4)


func _on_Coordinates_update_target(new_target:Vector2):
	"Update current target according to the targeting system."
	target = new_target


func _on_answer_text_changed(new_text):
	magnitude = int(new_text)


func _on_scalar_product_text_changed(new_text):
	scalar_value = int(new_text)


func _on_Level1_remove_attack(attack_number:int):
	if attack_number == 0:
		get_node("Nerfgun").button_mask = false
	elif attack_number == 1: 
		get_node("Stinkbomb").button_mask = false
	elif attack_number == 2: 
		get_node("Soap").button_mask = false
	elif attack_number == 3: 
		get_node("Water").button_mask = false
	elif attack_number == 4:
		get_node("Vaccine").button_mask = false
	elif attack_number == 5:
		get_node("Sleep").button_mask = false



func _on_Level1_reset_attacks():
	for button in buttons:
		button.button_mask = BUTTON_MASK_LEFT


func _on_Level1_ability_done(ability_counter:int):
	current_ability = 6
	target = Vector2()
	change_UI(6)
	change_tutorial(6)
	if ability_counter >= 2:
		for button in buttons:
			button.button_mask = false
	reset_coordinates()
	reset_magnitude()
	reset_vector_addition()
	reset_vector_dot_product()
	reset_vector_substraction()


func reset_vector_substraction():
	#Reset the values to defaut
	target = Vector2()
	get_node("Vector subtraction/Target").text = ""
	get_node("Vector subtraction/generated_vector").text = ""
	get_node("Vector subtraction/answer_x").text = ""
	get_node("Vector subtraction/answer_y").text = ""

func reset_coordinates():
	#Reset the values to defaut
	target = Vector2()
	get_node("Coordinates/Xcoord").text = "0"
	get_node("Coordinates/Ycoord").text = "0"

func reset_magnitude():
	#Reset the values to defaut
	target = Vector2()
	get_node("Magnitude/answer_box/Target").text = ""
	get_node("Magnitude/answer_box/answer").text = ""

func reset_vector_addition():
	#Reset the values to defaut
	target = Vector2()
	get_node("Vector addition/Target").text = ""
	get_node("Vector addition/generated_vector").text = ""
	get_node("Vector addition/answer_x").text = ""
	get_node("Vector addition/answer_y").text = ""

func reset_vector_dot_product():
	#Reset the values to default
	target = Vector2()
	get_node("Vector dot product/Target").text = ""
	get_node("Vector dot product/generated_vector").text = ""
	get_node("Vector dot product/scalar_product").text = ""
