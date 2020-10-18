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
var allyStationed = null
var enemyStationed = null
var movingUnits = []

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
	# Updates timer for tiles being built
	if !buildingComplete:
		if buildingTime <= 0:
			bldg_completeBuildingConstruction()
		else:
			bldg_continueBuildingConstruction(delta)
		
	# If the building produces units, is complete, and the tile is awake, CONTINUE PRODUCTION
	if unitProduction != null and buildingComplete and tileAwake:
		bldg_updateUnitProduction(delta)
		
	# Increments wakeTimer for sleeping tiles
	if not tileAwake:
		bldg_updateWakeTimer(delta)
			
	
func _ready():
	set_process(false)
	vision_checkIfSeen(self)
	
func unit_checkIfInMovingUnit(unit):
	if (unit in movingUnits):
		print("Unit found in moving units")
		return true
		
func unit_removeMovingUnit(removeThis):
	var index = 0
	for unit in movingUnits:
		if (unit == removeThis):
			movingUnits.remove(index)
			return
		else:
			index += 1

func unit_removeUnitCompletely(removeThis):
	if allyStationed == removeThis:
		allyStationed = null
	elif enemyStationed == removeThis:
		enemyStationed = null
	elif removeThis in movingUnits:
		unit_removeMovingUnit(removeThis)
	
	
func bldg_updateWakeTimer(delta):
	wakeTimer -= delta
	if wakeTimer <= 0:
		tileAwake = true
		print("TILE AWAKE")
	
func bldg_updateUnitProduction(delta):
	unitProduction -= delta
	if unitProduction < 0:
		bldg_createUnit()
		unitProduction = outputUnit
	else:
		# Show somewhere on a bar that units are being made
		pass

func bldg_completeBuildingConstruction():
	buildingComplete = true
	buildingTime = 0
	
	if unitProduction == null:
		set_process(false)
	get_node("TileHolder/BuildingProgressBar").hide()
	if buildingAlliance == "ally":
		vision_updateInSightOf(vision, self, true, true)
		stats_updateGlobalValues()
		
func bldg_continueBuildingConstruction(delta):
	buildingTime -= delta
	percentBuilt = (buildingTimeMax - buildingTime) / buildingTimeMax * 100
	get_node("TileHolder/BuildingProgressBar").set("value", percentBuilt)

func bldg_startBuilding():
	# Need to add functions that will trigger when a buildin begins to build
	# Things such as a building bar, locking uses until its done, etc.
	pass

func bldg_createTile():
	# Updates Portrait, desc, output
	stats_updateTileInfo()
	
	# Handles the time aspect to building a building.
	buildingTimeMax = buildingTime
	if currentlySeen:
		get_node("TileHolder/BuildingProgressBar").show()
	
	buildingComplete = false
	set_process(true)
	
func stats_updateGlobalValues():
	# Handles updating global production values
	get_tree().get_root().get_node("Control").updateTotalProduction(outputMana, outputAdvanced, outputResearch)

func stats_updateTileInfo():
	var data = databaseRef.getConstructionInfo(buildingName)
	
	description = data[0]
	portrait = data[1]
	buildingTime = data[2]
	buildingAlliance = data[3]
	vision = data[4]
	
	stats_updateOutput(data[5][0],data[5][1],data[5][2],data[5][3])
	
	# data[6] == unitName
	if data[6] != null:
		stats_setUnitCreationInfo(data[6])
	
	if buildingAlliance == "enemy":
		tileAwake = false
		bldg_activateEnemyTimer()
		vision_checkIfSeen(self)
	
func bldg_activateEnemyTimer():
	if distanceFromBase != 0:
		wakeTimer = distanceFromBase * wakeTimerConstant
		set_process(true)
	
func stats_setUnitCreationInfo(unitName):
	unitProductionName = unitName
	if buildingAlliance == "enemy":
		unitProductionIsAlly = false
	elif buildingAlliance == "ally":
		unitProductionIsAlly = true


func vision_updateInSightOf(toCheck, objectGivingSight, adding, isBuilding):
	var queueOfRemaining = [self]
	var arrayOfAll = []
	var tileToCheck
	var numberToCheckForAppend
	
	distanceFromOriginal = 0

	# If enemy unit, no need to continue
	if vision_returnIfEnemyUnitWhenCheckingVision(isBuilding, objectGivingSight):
		return
	
	# Main loop, goes through (Vision) amount of times
	tempVisionSeenOnce = true
	while(toCheck >= 0):
		
		# Appends or removes all members of 'inSightOf' for the tile
		for tile in queueOfRemaining:
			arrayOfAll.append(tile)
			
			vision_addOrRemoveFromSight(adding, objectGivingSight, tile)
		
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
	

func vision_addOrRemoveFromSight(adding, objectGivingSight, tile):
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
		tile.bldg_checkToWakeUp(distanceFromOriginal)
	
	# Remove items from inSightOf
	else:
		var index = 0
		for item in tile.inSightOf:
			if item == objectGivingSight:
				tile.inSightOf.remove(index)
			index += 1
	
	tile.vision_checkIfSeen(tile)

func vision_returnIfEnemyUnitWhenCheckingVision(isBuilding, objectGivingSight):
	# Is a unit
	if not isBuilding:
		# Is an ENEMY unit
		if not objectGivingSight.isAlly:
			vision_checkIfSeen(self)
			return true

func basic_resetTile():
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
	

func vision_checkIfSeen(tile):
	# Hidden
	if tile.inSightOf.empty():
		tile.get_node("TileHolder/Background/Unseen").show()
		tile.get_node("MapBackground").hide()
		tile.get_node("TileHolder/BuildingProgressBar").hide()
		tile.currentlySeen = false
		tile.vision_setEnemyVisibility(false)
	
	#Seen
	else:
		tile.get_node("TileHolder/Background/Unseen").hide()
		tile.get_node("MapBackground").show()
		if !(tile.buildingComplete):
			get_node("TileHolder/BuildingProgressBar").show()
		tile.currentlySeen = true
		tile.seenOnce = true
		tile.get_node("TileHolder/Background/Unseen").modulate = Color(1, 1, 1, 0.5)
		tile.vision_setEnemyVisibility(true)

func bldg_checkToWakeUp(distance):
	if wakeThreshold >= distance:
		tileAwake = true
		

func vision_setEnemyVisibility(tileSeen):
	if enemyStationed != null:
		if tileSeen:
			enemyStationed.show()
		else:
			enemyStationed.hide()

func stats_updateOutput(mana, unit, advanced, research):
	outputMana = mana
	outputUnit = unit
	unitProduction = outputUnit
	outputAdvanced = advanced
	outputResearch = research

func unit_appendUnitMoving(unit):
	if unit in movingUnits:
		return
	else:
		movingUnits.append(unit)

func unit_setUnitStationed(unit):
	allyStationed = unit
#	if enemyStationed != null:
#		inBattle = true
#		battle_snareBothUnits()
#		get_tree().get_root().get_node("Control/BattleScreen").addBattle(allyStationed, enemyStationed, self)
#		battle_showBattleButton()

func unit_setEnemyStationed(unit):
	enemyStationed = unit
#	if allyStationed != null:
#		inBattle = true
#		battle_snareBothUnits()
#		battle_showBattleButton()

func unit_getClosestMovingUnit():
	return movingUnits[0]

func battle_triggerBattleOnTile(ally, enemy):
	inBattle = true
	battle_snareBothUnits(ally, enemy)
	get_tree().get_root().get_node("Control/BattleScreen").addBattle(ally, enemy, self)
	battle_showBattleButton()
	
	ally.battle_enter()
	enemy.battle_enter()

func battle_snareBothUnits(ally, enemy):
	enemy.snared = true
	ally.snared = true

func battle_showBattleButton():
#	get_tree().get_root().get_node("Control/BattleScreen").addBattle(allyStationed, enemyStationed, self)
	get_node("TileHolder/ShowBattleButton").show()

func battle_hideBattleButton():
	get_node("TileHolder/ShowBattleButton").hide()
	
	# Gives enemies their last movement order so that they may continue.
	if enemyStationed != null:
		print("Giving the enemy it's last movement order")
		if (len(enemyStationed.pathToMove) != 0):
			enemyStationed.currentPath = enemyStationed.pathToMove
			enemyStationed.movement_updatePath()
		

func bldg_createUnit():
	var unit = null
	var newUnit = null
	
	if unitProductionIsAlly:
		unit = preload("../Units/Unit.tscn")
		newUnit = unit.instance()
	else:
		unit = preload("../Units/EnemyUnit.tscn")
		newUnit = unit.instance()
		
	newUnit.hostTile = self
	newUnit.stats_createUnit(unitProductionName, 1)
	
	
	if unitProductionIsAlly:
		if allyStationed == null:
			get_tree().get_root().get_node("Control/UnitHolder/UnitController").add_child(newUnit)
			newUnit.add_to_group("Units")
			newUnit.hostTile = self
			newUnit.set_position(Vector2(self.get_position()[0], self.get_position()[1] - 75))
			unit_setUnitStationed(newUnit)
		else:
			allyStationed.stats_mergeWithOtherGroup(newUnit)
	else:
		if enemyStationed == null:
			get_tree().get_root().get_node("Control/UnitHolder/EnemyController").add_child(newUnit)
			newUnit.add_to_group("Enemies")
			newUnit.hostTile = self
			newUnit.set_position(Vector2(self.get_position()[0] + 65, self.get_position()[1] - 75))
			unit_setEnemyStationed(newUnit)
			vision_checkIfSeen(self)
		else:
			enemyStationed.stats_mergeWithOtherGroup(newUnit)
	
func unit_getAllUnitsForTile():
	var returnUnits = []
	if allyStationed != null:
		returnUnits.append(allyStationed)
	if enemyStationed != null:
		returnUnits.append(enemyStationed)
	
	if (len(movingUnits) != 0):
		for unit in movingUnits:
			returnUnits.append(unit)
	
	return returnUnits
	
func unit_checkIfAnyUnitsOnThisTile(alliance):
	if alliance == "ally":
		for unit in movingUnits:
			if unit.isAlly:
				return true
		if allyStationed != null:
			return true
	
	else:
		for unit in movingUnits:
			if !unit.isAlly:
				return true
		if enemyStationed != null:
			return true
	
	return false

func basic_findDistanceFromBase(baseTile):
	distanceFromBase = rootRef.unitMovement.findDistanceBetweenTwoTiles(self, baseTile)
