extends Panel

const BASE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
const MANA_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
const MILITARY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
const RESOURCE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
const UTILITY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")
const ENEMY_TEST_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_EnemyTest.png")
const BLANK_PORTRAIT = preload("res://MainGame/Tiles/Resources/PH_Tile_Blank.png")

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
var tileAwake = true
var wakeThreshold = 1
var wakeTimer = 1
var wakeTimerConstant = 2

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
var distanceFromBase = 0

# Vision variables
var distanceFromOriginal = 0
var vision = 0
var inSightOf = []
var currentlySeen = false
var seenOnce = false
var tempVisionSeenOnce = false

var inBattle = false

onready var databaseRef = get_tree().get_root().get_node("Control").tileDatabase
onready var rootRef = get_tree().get_root().get_node("Control")

func _process(delta):
	if !buildingComplete:
		if buildingTime <= 0:
			completeBuildingConstruction()
		else:
			continueBuildingConstruction(delta)
		
	# If the building produces units, is complete, and the tile is awake, CONTINUE PRODUCTION
	if unitProduction != null and buildingComplete and tileAwake:
		updateUnitProduction(delta)
		
	if not tileAwake:
		wakeTimer -= delta
		if wakeTimer <= 0:
			tileAwake = true
			print("TILE AWAKE")
			
	
func _ready():
	set_process(false)
	checkIfSeen(self)
	
func updateUnitProduction(delta):
	unitProduction -= delta
	if unitProduction < 0:
		createUnit()
		unitProduction = outputUnit
	else:
		# Show somewhere on a bar that units are being made
		pass

func completeBuildingConstruction():
	buildingComplete = true
	buildingTime = 0
	
	if unitProduction == null:
		set_process(false)
	get_node("TileHolder/BuildingProgressBar").hide()
	if buildingAlliance == "ally":
		updateInSightOf(vision, self, true, true)
		updateGlobalValues()
		
func continueBuildingConstruction(delta):
	buildingTime -= delta
	percentBuilt = (buildingTimeMax - buildingTime) / buildingTimeMax * 100
	get_node("TileHolder/BuildingProgressBar").set("value", percentBuilt)

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
	
	# data[6] == unitName
	if data[6] != null:
		setUnitCreationInfo(data[6])
	
	if buildingAlliance == "enemy":
		tileAwake = false
		activateEnemyTimer()
		checkIfSeen(self)
	
func activateEnemyTimer():
	if distanceFromBase != 0:
		wakeTimer = distanceFromBase * wakeTimerConstant
		set_process(true)
	
func setUnitCreationInfo(unitName):
	unitProductionName = unitName
	if buildingAlliance == "enemy":
		unitProductionIsAlly = false
	elif buildingAlliance == "ally":
		unitProductionIsAlly = true


func updateInSightOf(toCheck, objectGivingSight, adding, isBuilding):
	var queueOfRemaining = [self]
	var arrayOfAll = []
	var tileToCheck
	var numberToCheckForAppend
	
	distanceFromOriginal = 0

	# If enemy unit, no need to continue
	if returnIfEnemyUnitWhenCheckingVision(isBuilding, objectGivingSight):
		return
	
	# Main loop, goes through (Vision) amount of times
	tempVisionSeenOnce = true
	while(toCheck >= 0):
		
		# Appends or removes all members of 'inSightOf' for the tile
		for tile in queueOfRemaining:
			arrayOfAll.append(tile)
			
			addOrRemoveFromSight(adding, objectGivingSight, tile)
		
		numberToCheckForAppend = queueOfRemaining.size()
		distanceFromOriginal += 1
		
		# Finds all adjacent tiles, adds them to queueOfRemaining
		while numberToCheckForAppend != 0 and toCheck > 0:
			
			numberToCheckForAppend -= 1
			tileToCheck = queueOfRemaining.pop_front()
			
			if tileToCheck.connections[0] == true and tileToCheck.aboveTile != null and !tileToCheck.aboveTile.tempVisionSeenOnce:
				queueOfRemaining.append(tileToCheck.aboveTile)
				tileToCheck.aboveTile.tempVisionSeenOnce = true
			if tileToCheck.connections[1] == true and tileToCheck.rightTile != null and !tileToCheck.rightTile.tempVisionSeenOnce:
				queueOfRemaining.append(tileToCheck.rightTile)
				tileToCheck.rightTile.tempVisionSeenOnce = true
			if tileToCheck.connections[2] == true and tileToCheck.belowTile != null and !tileToCheck.belowTile.tempVisionSeenOnce:
				queueOfRemaining.append(tileToCheck.belowTile)
				tileToCheck.belowTile.tempVisionSeenOnce = true
			if tileToCheck.connections[3] == true and tileToCheck.leftTile != null and !tileToCheck.leftTile.tempVisionSeenOnce:
				queueOfRemaining.append(tileToCheck.leftTile)
				tileToCheck.leftTile.tempVisionSeenOnce = true
				
		toCheck -= 1
		
	# Reset tempVision var
	for tile in arrayOfAll:
		tile.tempVisionSeenOnce = false
	

func addOrRemoveFromSight(adding, objectGivingSight, tile):
	# Adding items to inSightOf
	if adding:
		var newItem = true
		
		# Ensures this object isn't already listed in inSightOf
		for item in tile.inSightOf:
			if item == objectGivingSight:
				newItem = false
				
		#If it's a new item, add it to the list of inSightOf
		if newItem:
			tile.inSightOf.append(objectGivingSight)
			
		# Check if this is an enemy tile that needs to be woken up.
		tile.checkToWakeUp(distanceFromOriginal)
	
	# Remove items from inSightOf
	else:
		var index = 0
		for item in tile.inSightOf:
			if item == objectGivingSight:
				tile.inSightOf.remove(index)
			index += 1
	
	tile.checkIfSeen(tile)

func returnIfEnemyUnitWhenCheckingVision(isBuilding, objectGivingSight):
	# Is a unit
	if not isBuilding:
		# Is an ENEMY unit
		if not objectGivingSight.isAlly:
			checkIfSeen(self)
			return true

func resetTile():
	buildingName = "Blank"
	description = "aa"
	get_node("TileHolder/Background").set("texture", BLANK_PORTRAIT)
	buildingTime = 69
	buildingAlliance = "neutral"
	
	
	outputMana = null
	outputUnit = null
	unitProduction = null
	unitProductionName = null
	unitProductionIsAlly = null
	outputAdvanced = null
	outputResearch = null

	buildingComplete = true
	set_process(true)
	pass
	

func checkIfSeen(tile):
	# Hidden
	if tile.inSightOf.empty():
		tile.get_node("TileHolder/Background/Unseen").show()
		tile.get_node("MapBackground").hide()
		tile.get_node("TileHolder/BuildingProgressBar").hide()
		tile.currentlySeen = false
		tile.setEnemyVisibility(false)
	
	#Seen
	else:
		tile.get_node("TileHolder/Background/Unseen").hide()
		tile.get_node("MapBackground").show()
		if !(tile.buildingComplete):
			get_node("TileHolder/BuildingProgressBar").show()
		tile.currentlySeen = true
		tile.seenOnce = true
		tile.get_node("TileHolder/Background/Unseen").modulate = Color(1, 1, 1, 0.5)
		tile.setEnemyVisibility(true)

func checkToWakeUp(distance):
	if wakeThreshold >= distance:
		tileAwake = true
		

func setEnemyVisibility(tileSeen):
	if enemyStationed != null:
		if tileSeen:
			enemyStationed.show()
		else:
			enemyStationed.hide()

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
	
	# Gives enemies their last movement order so that they may continue.
	if enemyStationed != null:
		print("Giving the enemy it's last movement order")
		enemyStationed.currentPath = enemyStationed.pathToMove
		enemyStationed.updatePath()
		

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
			checkIfSeen(self)
		else:
			enemyStationed.mergeWithOtherGroup(newUnit)

func getStationaryUnitOnTile():
	for unit in get_tree().get_nodes_in_group("Units"):
		# Unit is sitting on top of this tile, not moving.
		if unit.hostTile == self and not unit.isMoving:
			return unit

func getAllUnitsStationed():
	var foundUnits = []
	for unit in get_tree().get_nodes_in_group("Units"):
		if unit.hostTile == self:
			foundUnits.append(unit)
	
	return foundUnits
	
func checkIfAnyUnitsOnThisTile(alliance):
	if alliance == "ally":
		for unit in get_tree().get_nodes_in_group("Units"):
			if unit.hostTile == self:
				return true

	else:
		for unit in get_tree().get_nodes_in_group("Enemies"):
			if unit.hostTile == self:
				return true
		
	return false
	
	

func findDistanceFromBase(baseTile):
	distanceFromBase = rootRef.unitMovement.findDistanceBetweenTwoTiles(self, baseTile)
