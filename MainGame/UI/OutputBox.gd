extends VBoxContainer

var totalMana = 0
var totalUnit = 0
var totalAdvanced = 0
var totalResearch = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func hideAll():
	for item in get_children():
		item.hide()
		
	# VERY INEFFICIENT for shift clicking more tiles. Good for double clicks or selecting large at once.
	totalMana = 0
	totalUnit = 0
	totalAdvanced = 0
	totalResearch = 0
		
func updateUI(tileGroup):
	hideAll()
	# For when a single tile is selected, not in a group.
	if typeof(tileGroup) == int(17):
		tileGroup = [tileGroup]
	
	for tile in tileGroup:
		if tile.outputMana != null:
			totalMana += tile.get("outputMana")
			get_node("ManaOutput/Label").set_text(str(totalMana))
			get_node("ManaOutput").show()
	
		if tile.outputUnit != null:
			totalUnit += tile.get("outputUnit")
			get_node("UnitOutput/Label").set_text(str(totalUnit))
			get_node("UnitOutput").show()
	
		if tile.outputAdvanced != null:
			totalAdvanced += tile.get("outputAdvanced")
			get_node("AdvancedOutput/Label").set_text(str(totalAdvanced))
			get_node("AdvancedOutput").show()
	
		if tile.outputResearch != null:
			totalResearch += tile.get("outputResearch")
			get_node("ResearchOutput/Label").set_text(str(totalResearch))
			get_node("ResearchOutput").show()
			

