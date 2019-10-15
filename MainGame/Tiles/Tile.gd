extends Panel

const BASE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
const MANA_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
const MILITARY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
const RESOURCE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
const UTILITY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")

const BASE_DESCRIPTION = "    The Center of Control for your operations. Provides basic resources along with " + \
	"access towards various upgrades."
const MANAPOOL_DESCRIPTION = "    This tile provides a steady supply of Mana to your CoC. It may be upgraded to " + \
	"increase the amount of mana generated, or even to provide healing towards troops stationed here."
const MILITARY_DESCRIPTION = "    This building creates troops for your army. It must be supplied with enough " + \
	"supplies to continue this production."
const UTILITY_DESCRIPTION = "    This does something, Utility is rather vague and can be a lot of things lmao"
const RESOURCE_DESCRIPTION = "    This building creates some arbitrary resource. Maybe it also consumes other " + \
	"resources to do so. idk"
	
var description = "TILE DESCRIPTION: NEEDS TO BE CHANGED"
var portrait = "Blank portrait??"

var buildingName = "Blank"
var buildingTime = 69
var buildingTimeMax = 69
var buildingComplete = false
var percentBuilt = 0

var outputMana = null
var outputUnit = null
var unitProduction = null
var outputAdvanced = null
var outputResearch = null

var row = null
var col = null

var selected = false
var unitStationed = null
var enemyStationed = null

var connections = []
var aboveTile
var rightTile
var belowTile
var leftTile

var vision = 0
var inSightOf = []
var currentlySeen = false
var seenOnce = false

var inBattle = false

func _process(delta):
	buildingTime -= delta
	if buildingTime <= 0:
		buildingTime = 0
		
		updateGlobalValues()
		
		if unitProduction == null:
			set_process(false)
		buildingComplete = true
		get_node("TileHolder/BuildingProgressBar").hide()
	else:
		percentBuilt = (buildingTimeMax - buildingTime) / buildingTimeMax * 100
		get_node("TileHolder/BuildingProgressBar").set("value", percentBuilt)
		
	if unitProduction != null:
		unitProduction -= delta
		if unitProduction < 0:
			createUnit()
			unitProduction = outputUnit
		else:
			# Show somewhere on a bar that units are being made
			pass
	
func _ready():
	set_process(false)
	checkIfSeen()
	pass # Replace with function body.

func startBuilding():
	pass

func createTile():
	# Updates Portrait, desc, output
	updateTileInfo()
	
	# Handles the time aspect to building a building.
	buildingTimeMax = buildingTime
	get_node("TileHolder/BuildingProgressBar").show()
	set_process(true)
	
func updateGlobalValues():
	# Handles updating global production values
	get_tree().get_root().get_node("Control").updateTotalProduction(outputMana, outputAdvanced, outputResearch)

func updateTileInfo():
	match buildingName:
		"Base":
			description = BASE_DESCRIPTION
			portrait = BASE_PORTRAIT
			buildingTime = 0
			updateOutput(10, null, 0, 3)
			vision = 2
			

		"ManaPool":
			description = MANAPOOL_DESCRIPTION
			portrait = MANA_PORTRAIT
			buildingTime = 0.5
			updateOutput(5, null, null, null)
			vision = 1

		"ResourceBldg":
			description = RESOURCE_DESCRIPTION
			portrait = RESOURCE_PORTRAIT
			buildingTime = 0.5
			updateOutput(-2, null, 1, null)
			vision = 1

		"MilitaryBldg":
			description = MILITARY_DESCRIPTION
			portrait = MILITARY_PORTRAIT
			buildingTime = 1
			updateOutput(null, 3, null, 0)
			vision = 2

		"UtilityBldg":
			description = UTILITY_DESCRIPTION
			portrait = UTILITY_PORTRAIT
			buildingTime = 15
			updateOutput(null, null, null, 5)
			vision = 3

		_:
			print("Tile.gd: No name match, given -" + buildingName)
	updateInSightOf(vision, self, true)
	
func updateInSightOf(toCheck, objectGivingSight, adding):
	var index = 0
	
	# Calls this function in each connected tile with 1 less range
	if toCheck != 0:
		if connections[0] == true:
			aboveTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[1] == true:
			rightTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[2] == true:
			belowTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[3] == true:
			leftTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
	if adding:
		inSightOf.append(objectGivingSight)
	else:
		for item in inSightOf:
			if item == objectGivingSight:
				inSightOf.remove(index)
			index += 1
	
	checkIfSeen()

func checkBattle():
	# If this is true, battleScreen is already available, nothing else to do. 
	# May need to include merging reinforcements, but that'll be taken care of later
	if inBattle == true:
		return
		
	if unitStationed != null and enemyStationed != null:
		get_tree().get_root().get_node("Control/BattleScreen").addBattle(unitStationed, enemyStationed, self)

func checkIfSeen():
	if inSightOf.empty():
		get_node("TileHolder/Unseen").show()
		get_node("MapBackground").hide()
		currentlySeen = false
	else:
		get_node("TileHolder/Unseen").hide()
		get_node("MapBackground").show()
		currentlySeen = true
		seenOnce = true
	
func updateOutput(mana, unit, advanced, research):
	outputMana = mana
	outputUnit = unit
	unitProduction = outputUnit
	outputAdvanced = advanced
	outputResearch = research

func setUnitStationed(unit):
	unitStationed = unit

func setEnemyStationed(unit):
	enemyStationed = unit

func createUnit():
	var unit = preload("../Units/Unit.tscn")
	
	var newUnit = unit.instance()
	newUnit.hostTile = self
	newUnit.createUnit("Goblin", 1)
	
	if unitStationed == null:
		get_tree().get_root().get_node("Control/UnitHolder/UnitController").add_child(newUnit)
		newUnit.add_to_group("Units")
		newUnit.setTile(self)
		newUnit.set_position(Vector2(self.get_position()[0], self.get_position()[1] - 75))
		setUnitStationed(newUnit)
	else:
		unitStationed.mergeWithOtherGroup(newUnit)

