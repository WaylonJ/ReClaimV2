extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var resourceBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/ResourceBldg"
	var militaryBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/MilitaryBldg"
	var utilityBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/UtilityBldg"
	hide()
	# Ok so this works functionally, still need to make it so that they hide
	# after you unhover. Also need to somehow pass the type of button hovered over.
	# Actualyl that might not be necessary if they all just get separate functions..
	get_node(resourceBldg).connect("mouse_entered", self, "_on_ResourceBldg_mouseEntered")
	get_node(resourceBldg).connect("mouse_exited", self, "hidePanel")
	get_node(militaryBldg).connect("mouse_entered", self, "_on_MilitaryBldg_mouseEntered")
	get_node(militaryBldg).connect("mouse_exited", self, "hidePanel")
	get_node(utilityBldg).connect("mouse_entered", self, "_on_UtilityBldg_mouseEntered")
	get_node(utilityBldg).connect("mouse_exited", self, "hidePanel")
	
func _on_ResourceBldg_mouseEntered():
	show()
	showPanel("Resource")
	
func _on_MilitaryBldg_mouseEntered():
	show()
	showPanel("Military")
	
func _on_UtilityBldg_mouseEntered():
	show()
	showPanel("Utility")
	
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
			print("Everything else??")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
