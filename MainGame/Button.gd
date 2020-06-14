extends Button

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	print(get_position())
	var cam = get_node("/root/Control/Camera2D")
	print("cam: " + str(cam.get_position()))
	set_position(cam.get_position())
