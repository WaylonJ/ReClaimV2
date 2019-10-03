extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.


func hideAll():
	for item in get_children():
		item.hide()
		
func updateUI(tile):
	hideAll()
	if tile.outputMana != null:
		get_node("ManaOutput").show()

	if tile.outputUnit != null:
		get_node("UnitOutput").show()

	if tile.outputAdvanced != null:
		get_node("AdvancedOutput").show()

	if tile.outputResearch != null:
		get_node("ResearchOutput").show()

