extends Path2D
class_name bomb
var num_of_points = 30
var gravity = -9.8
var target_map_location:Vector2
export(Resource) var map_info

func start(start_pos:Vector2, target_pos:Vector2, target_pos_in_map_coord:Vector2):
	#Set up the required info for bomb.
	target_map_location = target_pos_in_map_coord
	position = start_pos
	calculate_trajectory(start_pos, target_pos)

func calculate_trajectory(start_pos: Vector2, target_pos: Vector2):
	#Calculate the trajectory to move on
	var dot = Vector2(1,0).dot((target_pos - start_pos).normalized())
	var angle = 90 - 45 * dot
	
	var x_dis = target_pos.x - start_pos.x
	var y_dis = -(target_pos.y - start_pos.y)
	
	var speed = sqrt(((0.5 * gravity * x_dis * x_dis) / pow(cos(deg2rad(angle)),2)) / (y_dis - (tan(deg2rad(angle)) * x_dis)))
	var x_component = (cos(deg2rad(angle)) * speed)
	var y_component = (sin(deg2rad(angle)) * speed)
	var new_curve = Curve2D.new()
	var total_time = 0
	if x_component != 0:
		total_time = x_dis / x_component
		for point in num_of_points:
			var time:float = float(total_time) * (float(point) / float(num_of_points))
			var dx = time * x_component
			var dy = -(time * y_component + 0.5 * gravity * time * time)
			new_curve.add_point(Vector2(dx,dy))
	elif x_component == 0:
		total_time = 10.0
		var displacement_vector = target_pos - start_pos
		for point in num_of_points:
			var displacement_fraction = float(point) / float(num_of_points)
			var current_displacement = displacement_vector * displacement_fraction
			new_curve.add_point(current_displacement)
	curve = new_curve
	$Tween.interpolate_property($PathFollow2D,
								"unit_offset",
								0.0,
								1.0,
								total_time / 10.0,
								Tween.TRANS_QUAD,
								Tween.EASE_IN)
	$Tween.start()



func _on_Tween_tween_completed(_object, key):
	if key == ":unit_offset":
		map_info.check_for_damage(target_map_location)
		map_info.check_for_push(target_map_location)
		queue_free()

