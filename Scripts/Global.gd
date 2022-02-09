extends Node

var round_number = 1
var building_health = 7
var level2 = [-1,-1,-1,-1,-1,-1,-1,-1,0,2,-1,-1,-1,-1,-1,-1,-1,-1,-1,2,3,-1,-1,-1,-1,-1,-1,
-1,-1,-1,-1,3,2,1,-1,3,-1,-1,-1,3,2,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,3,-1,-1,-1,-1]
var level3 = [-1,-1,-1,-1,-1,-1,-1,3,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
			3,0,1,2,-1,-1,-1,-1,3,3,2,1,0,-1,3,-1,3,3,3,2,-1,-1,-1,-1,3,3,3,3,-1,-1,-1,-1]

# Called when the node enters the scene tree for the first time.
func _ready():
	TranslationServer.set_locale("et")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func next_round():
	
	print("next round has begun")

