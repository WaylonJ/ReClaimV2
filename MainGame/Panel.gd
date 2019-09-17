extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	# Ok so this works functionally, still need to make it so that they hide
	# after you unhover. Also need to somehow pass the type of button hovered over.
	# Actualyl that might not be necessary if they all just get separate functions..
	$"../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow".connect("mouse_entered", self, "_on_BottomUI_mouseEntered")
	
func _on_BottomUI_mouseEntered():
	show()
	showPanel("Resource")
	
func showPanel(type):
	match type:
		"Resource":
			pass
		"Military":
			pass
		"Utility":
			pass
		_:
			print("Everything else??")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
