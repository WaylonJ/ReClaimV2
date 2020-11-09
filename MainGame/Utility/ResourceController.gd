extends Node

# Variables that control player resources
var manaProduction = 0
var advancedProduction = 0
var researchProduction = 0

var manaSupply = 750
var advancedSupply = 100
var researchSupply = 100

var manaCap = 1000
var advancedCap = 500

# Ref vars
var baseTile = null
#var baseTile = get_parent().baseTile

# Utility vars
var myTimerReset = 0.02
var myTimer = 0.02
var incInWhile = 0
var incOutWhile = 0
var incremented = false
var TIME_CONSTANT = 50.0


func _ready():
	get_parent().timeController.object_addItemToGroup(self, "Resources")
	pass

func _init():
	pass

func time_Update():
	manaSupply += manaProduction / TIME_CONSTANT
	advancedSupply += advancedProduction / TIME_CONSTANT
	researchSupply += researchProduction / TIME_CONSTANT
	
	checkCaps()
	updateUI()
	

func addBaseTile(tile):
	baseTile = tile

func updateTotalProduction(mana, advanced, research):
	if mana != null:
		manaProduction += mana
	if advanced != null:
		advancedProduction += advanced
	if research != null:
		researchProduction += research
		
	# Updates the baseTile values and the UI portion
	baseTile.set("outputMana", manaProduction)
	baseTile.set("outputAdvanced", advancedProduction)
	baseTile.set("outputResearch", researchProduction)
	get_parent().get_node("UI/BottomUI/MiddleSection/TileInfo/Production/OutputBox").updateUI(baseTile)

func updateUI():
	var mana = get_parent().get_node("UI/BottomUI/RightSection/ResourceItems/Mana")
	var advanced = get_parent().get_node("UI/BottomUI/RightSection/ResourceItems/Advanced")
	var research = get_parent().get_node("UI/BottomUI/RightSection/ResourceItems/Research")
	
	mana.get_node("Label").set_text(str(floor(manaSupply)))
	advanced.get_node("Label").set_text(str(floor(advancedSupply)))
	research.get_node("Label").set_text(str(floor(researchSupply)))
	
func checkCaps():
	if manaSupply > manaCap:
		manaSupply = manaCap
	if advancedSupply > advancedCap:
		advancedSupply = advancedCap

func checkSupply(manaCost, advancedCost):
	if manaSupply >= manaCost and advancedSupply >= advancedCost:
		return true
	else:
		return false

func checkBuildable(manaCost, advancedCost):
	if checkSupply(manaCost, advancedCost):
		manaSupply -= manaCost
		advancedSupply -= advancedCost
		return true
	else:
		return false
	
func add_resources(manaCost, advancedCost):
	manaSupply += manaCost
	advancedSupply += advancedCost
	checkCaps()
