extends TextureRect

var buttonCoordinates = []
var test = "../../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/ResourceBldg"
#
#func _init():
#	MOUSE_FILTER_PASS = 1

func _ready():
#	var resourceBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/ResourceBldg"
#	var militaryBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/MilitaryBldg"
#	var utilityBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/UtilityBldg"
#	hide()
#	# Ok so this works functionally, still need to make it so that they hide
#	# after you unhover. Also need to somehow pass the type of button hovered over.
#	# Actualyl that might not be necessary if they all just get separate functions..
#	get_node(resourceBldg).connect("mouse_entered", self, "_on_ResourceBldg_mouseEntered")
#	get_node(resourceBldg).connect("mouse_exited", self, "hidePanel")
#	get_node(militaryBldg).connect("mouse_entered", self, "_on_MilitaryBldg_mouseEntered")
#	get_node(militaryBldg).connect("mouse_exited", self, "hidePanel")
#	get_node(utilityBldg).connect("mouse_entered", self, "_on_UtilityBldg_mouseEntered")
#	get_node(utilityBldg).connect("mouse_exited", self, "hidePanel")
	hide()
	var buttons = get_tree().get_nodes_in_group("ConstructionButtons")
#
#	print(get_node(test).get_position())
	
	for item in buttons:
		item.connect("pressed", self, "_on_thisButton_pressed", [item])

func _on_thisButton_pressed(button):
	var buttonPos = button.get_position()
	var parentPos = button.get_parent().get_position()
	print("SelectedHighlight.gd: " + str(buttonPos) + ", parent: " + str(parentPos))
	set_position(buttonPos + parentPos + Vector2(598, 540))
#	get_tree().get_root().get_child(0).set("selectedTile", button.get_name())
#	print(get_tree().get_root().get_child(0).get("selectedTile"))
#	button.get_name())
	show()


#func _unhandled_input(event):
#	print(event)