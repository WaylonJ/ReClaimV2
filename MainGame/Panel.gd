extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	connectBldgButtons()

func connectBldgButtons():
	var resourceBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/ResourceBldg"
	var militaryBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/MilitaryBldg"
	var utilityBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/UtilityBldg"
	
	get_node(resourceBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Resource"])
	get_node(resourceBldg).connect("mouse_exited", self, "hidePanel")
	get_node(militaryBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Military"])
	get_node(militaryBldg).connect("mouse_exited", self, "hidePanel")
	get_node(utilityBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Utility"])
	get_node(utilityBldg).connect("mouse_exited", self, "hidePanel")

func _on_BldgButton_mouseEntered(typeOfBuilding):
	show()
	showPanel(typeOfBuilding)
	
func hidePanel():
	hide()
	
func showPanel(type):
	match type:
		"Resource":
			get_node("PanelText").text = "Structures who's main focus is gathering basic resources or enhancing them into something more advanced. \n\n -Mana Pool\n -tempResourceStructre\n -Locked\n -Locked"
		"Military":
			get_node("PanelText").text = "Structures that produce Units or other benefits towards your military strength.\n\n -Goblin Hut\n -Fairy Garden\n -Locked\n -Locked\n -Locked"
		"Utility":
			get_node("PanelText").text = "Structures that provide a variety of unique benefits, usually involved in gathering information or enhancing some system.\n\n -Lookout Tower\n -Mana Analyzer\n -Locked"
		_:
			print("Panel.gd: Everything else??")
