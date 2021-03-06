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
var wakeTimerConstant = 0.1

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
var inBattle = false

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
var inSightOf = {}
var currentlySeen = false
var seenOnce = false
var tempVisionSeenOnce = false
var lightLevel = -1

# Event variables
var event
var eventType = ""
var eventCollideable = false


onready var databaseRef = get_tree().get_root().get_node("Control").tileDatabase
onready var rootRef = get_tree().get_root().get_node("Control")
onready var resourceController = rootRef.resourceController
onready var timeController = rootRef.timeController
onready var TIME_CONSTANT = timeController.TIME_CONSTANT


func time_Update():
	# Updates timer for tiles being built
	if !buildingComplete:
		if buildingTime <= 0:
			bldg_completeBuildingConstruction()
		else:
			bldg_continueBuildingConstruction()
		
	# If the building produces units, is complete, and the tile is awake, CONTINUE PRODUCTION
	if unitProduction != null and buildingComplete and tileAwake:
		bldg_updateUnitProduction()
		
	# Increments wakeTimer for sleeping tiles
	if not tileAwake:
		bldg_updateWakeTimer()

func time_CheckIfNeeded():
	# If any of the following occur, then add self to timeController. Otherwise no need to track.
	
	if !buildingComplete:
		timeController.object_addItemToGroup(self, "Buildings")
	if unitProduction != null and buildingComplete and tileAwake:
		timeController.object_addItemToGroup(self, "Buildings")
	if not tileAwake:
		timeController.object_addItemToGroup(self, "Buildings")
	
func _ready():
	vision_checkIfSeen(self)
	
func event_add(newEvent):
	event = newEvent
	eventType = event.get_type()
	
	add_child(event)
	event.add_parent(self)
	
	buildingName = "PopupEvent"
	buildingAlliance = "unique"
	
	description = event.get_description()
	portrait = event.get_portrait()
	get_node("TileHolder/Background").set("texture", portrait)
	
	
	match eventType:
		# This type of event triggers once an ally unit moves over it.
		"popup":
			eventCollideable = true
			
		_:
			print("Non-existant Event Type")
			
func event_remove():
	remove_child(event)
	
	buildingName = "Blank"
	buildingAlliance = "neutral"
	
	description = "TILE DESCRIPTION: NEEDS TO BE CHANGED"
	portrait = BLANK_PORTRAIT
	get_node("TileHolder/Background").set("texture", portrait)
	
	event = null
	eventType = null
	eventCollideable = false
	

func event_Trigger():
	event.triggerEvent()

func unit_checkIfInMovingUnit(unit):
	if (unit in movingUnits):
#		print("Unit found in moving units")
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
	
	
func bldg_updateWakeTimer():
	wakeTimer -= TIME_CONSTANT
	if wakeTimer <= 0:
		tileAwake = true
	
func bldg_updateUnitProduction():
	unitProduction -= TIME_CONSTANT
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
		timeController.object_removeItemFromGroup(self, "Buildings")
	get_node("TileHolder/BuildingProgressBar").hide()
	if buildingAlliance == "ally":
		vision_updateInSightOf(vision, self, true, true)
		resourceController.updateTotalProduction(outputMana, outputAdvanced, outputResearch)
		
func bldg_continueBuildingConstruction():
	buildingTime -= TIME_CONSTANT
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
	time_CheckIfNeeded()

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
		time_CheckIfNeeded()
	
func stats_setUnitCreationInfo(unitName):
	unitProductionName = unitName
	if buildingAlliance == "enemy":
		unitProductionIsAlly = false
	elif buildingAlliance == "ally":
		unitProductionIsAlly = true

func vision_checkIfEdgeOfVision(adding, objectGivingSight, tile, toCheck):
#	print(tile.lightLevel)
	
	for child in tile.get_node("LightShades").get_children():
		child.hide()
	
	# If it has light level 2 or higher, give it full vision.
	if(tile.lightLevel >= 2):
		return
		
	# Assuming it's light level == 1. Need to find adjacent lightLevel == 2 tiles to
	# determine the right modulate to apply.
	
	# Up, right, down, left
	var conns = [0, 0, 0, 0]
	
	if tile.connections[0] == true and tile.aboveTile != null and tile.aboveTile.lightLevel == 2:
		conns[0] = 1
	if tile.connections[1] == true and tile.rightTile != null and tile.rightTile.lightLevel == 2:
		conns[1] = 1
	if tile.connections[2] == true and tile.belowTile != null and tile.belowTile.lightLevel == 2:
		conns[2] = 1
	if tile.connections[3] == true and tile.leftTile != null and tile.leftTile.lightLevel == 2:
		conns[3] = 1
	
	match conns:
		# 1 sources
		[0, 0, 0, 0]:
#			print("a")
			tile.get_node("LightShades/0Source").show()
		
		# 1 sources
		[1, 0, 0, 0]:
			tile.get_node("LightShades/1SourceTop").show()
		[0, 1, 0, 0]:
			tile.get_node("LightShades/1SourceRight").show()
		[0, 0, 1, 0]:
			tile.get_node("LightShades/1SourceBot").show()
		[0, 0, 0, 1]:
			tile.get_node("LightShades/1SourceLeft").show()
#		[0, 0, 0, 0]
		# 2 sources (opposite)
		[1, 0, 1, 0]:
			tile.get_node("LightShades/2SourceVertical").show()
		[0, 1, 0, 1]:
			tile.get_node("LightShades/2SourceHorizontal").show()
		
		# 2 sources (adjacent)
		[1, 1, 0, 0]:
			tile.get_node("LightShades/2SourceTopRight").show()
		[0, 1, 1, 0]:
			tile.get_node("LightShades/2SourceRightBot").show()
		[0, 0, 1, 1]:
			tile.get_node("LightShades/2SourceBotLeft").show()
		[1, 0, 0, 1]:
			tile.get_node("LightShades/2SourceLeftTop").show()
		
		# 3 sources
		[0, 1, 1, 1]:
			tile.get_node("LightShades/3SourceTop").show()
		[1, 0, 1, 1]:
			tile.get_node("LightShades/3SourceRight").show()
		[1, 1, 0, 1]:
			tile.get_node("LightShades/3SourceBot").show()
		[1, 1, 1, 0]:
			tile.get_node("LightShades/3SourceLeft").show()
		
		# 4 sources
		[1, 1, 1, 1]:
			tile.get_node("LightShades/4Source").show()

func vision_updateInSightOf(toCheck, objectGivingSight, adding, isABuilding):
	var queueOfRemaining = [self]
	var arrayOfAll = []
	var tileToCheck
	var numberToCheckForAppend
	
	distanceFromOriginal = 0

	# If enemy unit, no need to continue
	if vision_returnIfEnemyUnitWhenCheckingVision(isABuilding, objectGivingSight):
		return
	
	# Main loop, goes through (Vision) amount of times
	tempVisionSeenOnce = true
	while(toCheck >= 0):
		
		# Appends or removes all members of 'inSightOf' for the tile
		for tile in queueOfRemaining:
			arrayOfAll.append(tile)
			
			vision_addOrRemoveFromSight(adding, objectGivingSight, tile, toCheck + 1)
			vision_updateLightLevel(tile)
			vision_checkIfEdgeOfVision(adding, objectGivingSight, tile, toCheck)
		
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
	

func vision_updateLightLevel(tile):
	var highestLevel = 0
#	print("In updateLightLevel, tile.inSightOf(): " + str(tile.inSightOf))
	for source in tile.inSightOf:
		if tile.inSightOf[source] > highestLevel:
			highestLevel = tile.inSightOf[source]
	
	tile.lightLevel = highestLevel

func vision_addOrRemoveFromSight(adding, objectGivingSight, tile, newLightLevel):
	# Adding items to inSightOf
	if adding:
#		print("insight of (+) Tile: " + str(tile) + ", object: " + str(objectGivingSight))
		tile.inSightOf[objectGivingSight] = newLightLevel
	
	# Remove items from inSightOf
	else:
#		print("insight of (-) Tile: " + str(tile) + ", object: " + str(objectGivingSight))
		tile.inSightOf.erase(objectGivingSight)
	
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
	time_CheckIfNeeded()

func vision_checkIfSeen(tile):
	# Hidden, hide most things
	if tile.inSightOf.empty():
		tile.get_node("TileHolder/Background/Unseen").show()
#		tile.get_node("MapBackground").hide()
		tile.get_node("TileHolder/BuildingProgressBar").hide()
		tile.currentlySeen = false
		tile.vision_setEnemyVisibility(false)
	
	#Seen, show most things
	else:
		tile.get_node("TileHolder/Background/Unseen").hide()
		tile.get_node("TileHolder/Background/Unseen").modulate = Color(1, 1, 1, 0.5)
		tile.get_node("MapBackground").show()
		tile.get_node("Walls").show()
		if !(tile.buildingComplete):
			get_node("TileHolder/BuildingProgressBar").show()
		tile.currentlySeen = true
		tile.seenOnce = true
		
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

func stats_updateOutput(mana, advanced, unit, research):
	outputMana = mana
	outputAdvanced = advanced
	outputUnit = unit
	unitProduction = outputUnit
	outputResearch = research

func unit_appendUnitMoving(unit):
	if unit in movingUnits:
		return
	else:
		movingUnits.append(unit)

func unit_setUnitStationed(unit):
	allyStationed = unit

func unit_setEnemyStationed(unit):
	enemyStationed = unit

func unit_getClosestMovingUnit():
	return movingUnits[0]

func battle_triggerBattleOnTile(ally, enemy):
	inBattle = true
	get_tree().get_root().get_node("Control/BattleScreen").addBattle(ally, enemy, self)
	battle_showBattleButton()
	
	ally.battle_enter()
	enemy.battle_enter()

func battle_checkRefresh():
	if inBattle:
		rootRef.get_node("BattleScreen").refreshUnits(self)

func battle_showBattleButton():
#	get_tree().get_root().get_node("Control/BattleScreen").addBattle(allyStationed, enemyStationed, self)
	get_node("TileHolder/ShowBattleButton").show()

func battle_hideBattleButton():
	get_node("TileHolder/ShowBattleButton").hide()
	
#	# Gives enemies their last movement order so that they may continue.
#	if enemyStationed != null:
#		if (len(enemyStationed.pathToMove) > 0):
#			print("Giving the enemy it's last movement order")
#			enemyStationed.currentPath = enemyStationed.pathToMove
#			enemyStationed.movement_updatePath()
		
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
	
func unit_checkIfAnyUnitsOnThisTile(ally):
	if ally:
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
