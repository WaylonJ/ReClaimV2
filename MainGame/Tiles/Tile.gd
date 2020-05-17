extends Panel

const BASE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
const MANA_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
const MILITARY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
const RESOURCE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
const UTILITY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")
const ENEMY_TEST_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_EnemyTest.png")

const BASE_DESCRIPTION = "    The Center of Control for your operations. Provides basic resources along with " + \
	"access towards various upgrades."
const MANAPOOL_DESCRIPTION = "    This tile provides a steady supply of Mana to your CoC. It may be upgraded to " + \
	"increase the amount of mana generated, or even to provide healing towards troops stationed here."
const MILITARY_DESCRIPTION = "    This building creates troops for your army. It must be supplied with enough " + \
	"supplies to continue this production."
const UTILITY_DESCRIPTION = "    This does something, Utility is rather vague and can be a lot of things lmao"
const RESOURCE_DESCRIPTION = "    This building creates some arbitrary resource. Maybe it also consumes other " + \
	"resources to do so. idk"
const ENEMY_TEST = "    This building creates basic enemy troops, similar to the current Military bldg " + \
	"They will be constantly stationed and idk if this will ever be seen."
	
var description = "TILE DESCRIPTION: NEEDS TO BE CHANGED"
var portrait = "Blank portrait??"

var buildingName = "Blank"
var buildingTier = 1
var buildingTime = 69
var buildingTimeMax = 69
var buildingComplete = true
var percentBuilt = 0
var buildingAlliance = "neutral"

# Build production variables
var outputMana = null
var outputUnit = null
var unitProduction = null
var unitProductionName = null
var unitProductionIsAlly

var outputAdvanced = null
var outputResearch = null

var row = null
var col = null

# Unit selection / stationed variables
var selected = false
var unitStationed = null
var enemyStationed = null

# Connections to other tiles variables
var connections = []
var aboveTile
var rightTile
var belowTile
var leftTile

# Vision variables
var vision = 0
var inSightOf = []
var currentlySeen = false
var seenOnce = false

var inBattle = false

var tileDatabase = preload("res://MainGame/Tiles/TileDatabase.gd")
var databaseRef = tileDatabase.new()

func _process(delta):
	buildingTime -= delta
	if !buildingComplete:
		if buildingTime <= 0:
			buildingComplete = true
			buildingTime = 0
			
			updateGlobalValues()
			
			if unitProduction == null:
				set_process(false)
			get_node("TileHolder/BuildingProgressBar").hide()
		
		else:
			percentBuilt = (buildingTimeMax - buildingTime) / buildingTimeMax * 100
			get_node("TileHolder/BuildingProgressBar").set("value", percentBuilt)
		
	if unitProduction != null and buildingComplete:
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
	
func startBuilding():
	# Need to add functions that will trigger when a buildin begins to build
	# Things such as a building bar, locking uses until its done, etc.
	pass

func createTile():
	# Updates Portrait, desc, output
	updateTileInfo()
	
	# Handles the time aspect to building a building.
	buildingTimeMax = buildingTime
	if currentlySeen:
		get_node("TileHolder/BuildingProgressBar").show()
	
	buildingComplete = false
	set_process(true)
#	get_node("../../BottomUI/MiddleSection/TileInfo").updateUI()
	
func updateGlobalValues():
	# Handles updating global production values
	get_tree().get_root().get_node("Control").updateTotalProduction(outputMana, outputAdvanced, outputResearch)

func updateTileInfo():
	var data = databaseRef.getConstructionInfo(buildingName)
	
	description = data[0]
	portrait = data[1]
	buildingTime = data[2]
	buildingAlliance = data[3]
	vision = data[4]
	
	updateOutput(data[5][0],data[5][1],data[5][2],data[5][3])
	
	if data[6] != null:
		setUnitCreationInfo(data[6])
	
	if buildingAlliance != "enemy":
		updateInSightOf(vision, self, true)
	
func setUnitCreationInfo(unitName):
	unitProductionName = unitName
	if buildingAlliance == "enemy":
		unitProductionIsAlly = false
	elif buildingAlliance == "ally":
		unitProductionIsAlly = true


func updateInSightOf(toCheck, objectGivingSight, adding):
	var index = 0
	
	# Calls this function in each connected tile with 1 less range
	if toCheck != 0:
		if connections[0] == true and aboveTile != null:
			aboveTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[1] == true and rightTile != null:
			rightTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[2] == true and belowTile != null:
			belowTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
		if connections[3] == true and leftTile != null:
			leftTile.updateInSightOf(toCheck - 1, objectGivingSight, adding)
	if adding:
		inSightOf.append(objectGivingSight)
	else:
		for item in inSightOf:
			if item == objectGivingSight:
				inSightOf.remove(index)
			index += 1
	
	checkIfSeen()

func checkIfSeen():
	# Hidden
	if inSightOf.empty():
		get_node("TileHolder/Unseen").show()
		get_node("MapBackground").hide()
		get_node("TileHolder/BuildingProgressBar").hide()
		currentlySeen = false
		if enemyStationed != null:
			enemyStationed.hide()
	
	#Seen
	else:
		get_node("TileHolder/Unseen").hide()
		get_node("MapBackground").show()
		if !(buildingComplete):
			get_node("TileHolder/BuildingProgressBar").show()
		currentlySeen = true
		seenOnce = true
		if enemyStationed != null:
			enemyStationed.show()
	
func updateOutput(mana, unit, advanced, research):
	outputMana = mana
	outputUnit = unit
	unitProduction = outputUnit
	outputAdvanced = advanced
	outputResearch = research

func setUnitStationed(unit):
	unitStationed = unit
	if enemyStationed != null:
		inBattle = true
		snareBothUnits()
		showBattleButton()

func setEnemyStationed(unit):
	enemyStationed = unit
	if unitStationed != null:
		inBattle = true
		snareBothUnits()
		showBattleButton()

func snareBothUnits():
	enemyStationed.snared = true
	unitStationed.snared = true

func showBattleButton():
	get_tree().get_root().get_node("Control/BattleScreen").addBattle(unitStationed, enemyStationed, self)
	get_node("TileHolder/ShowBattleButton").show()

func hideBattleButton():
	get_node("TileHolder/ShowBattleButton").hide()

func createUnit():
	var unit = null
	var newUnit = null
	
	if unitProductionIsAlly:
		unit = preload("../Units/Unit.tscn")
		newUnit = unit.instance()
	else:
		unit = preload("../Units/EnemyUnit.tscn")
		newUnit = unit.instance()
		
	newUnit.hostTile = self
	newUnit.createUnit(unitProductionName, 1)
	
	
	if unitProductionIsAlly:
		if unitStationed == null:
			get_tree().get_root().get_node("Control/UnitHolder/UnitController").add_child(newUnit)
			newUnit.add_to_group("Units")
			newUnit.setTile(self)
			newUnit.set_position(Vector2(self.get_position()[0], self.get_position()[1] - 75))
			setUnitStationed(newUnit)
		else:
			unitStationed.mergeWithOtherGroup(newUnit)
	else:
		if enemyStationed == null:
			get_tree().get_root().get_node("Control/UnitHolder/EnemyController").add_child(newUnit)
			newUnit.add_to_group("Enemies")
			newUnit.setTile(self)
			newUnit.set_position(Vector2(self.get_position()[0] + 65, self.get_position()[1] - 75))
			setEnemyStationed(newUnit)
		else:
			enemyStationed.mergeWithOtherGroup(newUnit)

