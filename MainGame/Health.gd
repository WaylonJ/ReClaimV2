extends TextureProgress

func _ready():
	pass
#	setDefaultHeight()
	
func setDefaultHeight():
	var parent = get_parent()
	var pos = parent.get_position()
	print("My rect: " + str(pos))
	set_position(Vector2(pos[0] + 20, pos[1] + 20))





