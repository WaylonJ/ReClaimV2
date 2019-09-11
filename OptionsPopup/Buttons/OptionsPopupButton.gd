extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	var test = get_node("/root/")
	var test2 = get_parent().get_parent().rect_size
	print("aaA" + str(test.get_child(0).get_children()))
	print(test2)
	print(rect_size)
	rect_size = Vector2(100, 100)
	print(rect_size)
#	print(test.rect_size)

func _pressed():
	rect_size = Vector2(100, 100)
	print(rect_size)
	
