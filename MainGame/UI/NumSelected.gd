extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.

func setCounter(num):
	set_text(str(num))
	
	if num == 0 or num == 1:
		hide()
	else:
		show()
	