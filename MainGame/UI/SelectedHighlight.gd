extends TextureRect

var buttonCoordinates = []
var test = "../../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/AdvResourceBldg"

export var selectedBldg = "a"

func _ready():

	hide()
	var buttons = get_tree().get_nodes_in_group("ConstructionButtons")
	
	for item in buttons:
		item.connect("pressed", self, "_on_thisButton_pressed", [item])

func _on_thisButton_pressed(button):
	var buttonPos = button.get_position()
	var parentPos = button.get_parent().get_position()
	selectedBldg = button.get_name()
	
#	print("SelectedHighlight.gd: " + str(buttonPos) + ", parent: " + str(parentPos))
	set_position(buttonPos + parentPos + Vector2(690, 540))
	show()
