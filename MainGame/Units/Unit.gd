extends Button

# Constants
const DIST_CONSTANT = 10

# Unit type scripts
var leaderScript = load("res://MainGame/Units/UnitTypes/Leader.gd")
var goblinScript = load("res://MainGame/Units/UnitTypes/Goblin.gd")

# References to the Unit types and num of Units
var unitRefs = {}
var leaderRef
var goblinRef

var numLeader = 0
var numGoblin = 0
var numUnits = 0

# Misc. variables
var isAlly = true
var isMoving = false
var unitTypes = []
var portrait

# Unit stat variables
var totalCurrentHealth = 0
var totalMaxHealth = 0
var totalOffense = 0
var totalDefense = 0
var totalSpeed = 0
var vision = 0
var formation = {}

# Movement vars
var pathToMove = []
var currentPath = []
onready var rootRef = get_tree().get_root().get_node("Control")

var distanceTotal
var distanceLeft
var distanceMovedSinceLastTick = 0
var directionMoving

var hostTile = null
var prevTile = null

var snared = false

func _ready():
	self.connect("mouse_entered", get_tree().get_root().get_node("Control/UnitHolder/UnitController"), "_mouseEntered", [self])
	self.connect("mouse_exited", get_tree().get_root().get_node("Control/UnitHolder/UnitController"), "_mouseExited")
	set_process(false)

func _init():
	basic_generateUnitRefs()

func _process(delta):
	movement_updateMovement(delta)
	

func movement_updateMovement(delta):
	distanceLeft -= delta * totalSpeed
	distanceMovedSinceLastTick += (delta * totalSpeed) / numUnits
	
	# Progress unit towards next tile visually
	if distanceMovedSinceLastTick >= 1:
		movement_moveUnitAlongPath(distanceMovedSinceLastTick * 10)
		distanceMovedSinceLastTick -= 1
	
	# Units has reached its destination
	if distanceLeft < 0:
		set_process(false)
		
		if isAlly:
			hostTile.vision_updateInSightOf(vision, self, false, false)
		movement_updatePath()

func basic_generateUnitRefs():
	leaderRef = leaderScript.new()
	add_child(leaderRef)
	
	goblinRef = goblinScript.new()
	add_child(goblinRef)

func movement_appendPath(newPath, replacing):
	if replacing:
		# Start of new movement order, check if currently moving
		if (isMoving == true):
			movement_checkIfTurnAroundNeeded(newPath)
		
		else:
			isMoving = true
			hostTile.unit_removeUnitCompletely(self)
			currentPath = newPath
#			hostTile = null
			movement_updatePath()
	else:
		for item in newPath:
			currentPath.append(item)
		
	# STILL NEED TO IMPLEMENT SHIFT CLICKING FOR SPECIFIC PATHS
#	elif replacing:
#		returnUnitToHostTile()

func movement_checkIfTurnAroundNeeded(newPath):
	# If length is 0, unit is being asked to return to prev Tile
	if newPath.size() == 1:
		print("Return to host")
		ui_switchDirections()
	
	# Check if the newPath's first next tile is the same as the one currently being traveled to.
	elif newPath[1] == currentPath[0]:
		newPath.pop_front()
	
	# The unit needs to turn around, then reset the path
	else:
		print("Turn around, then continue on path")
		ui_switchDirections()
		if currentPath[0] == newPath[0]:
			var size = newPath.size()
			
			# Needs to create a new path starting from the tile it's currently traveling to.
			newPath = rootRef.unitMovement.findShortestPath(hostTile, newPath[size - 1])
	
	currentPath = newPath

func ui_switchDirections():
	# Sets this so if multiple switch backs occur, the unit doesn't teleport when the path is replaced.
	hostTile = currentPath[0]
	
	directionMoving = movement_setOppositeDirection()
	distanceLeft = (DIST_CONSTANT * numUnits) - distanceLeft

func movement_setOppositeDirection():
	match directionMoving:
		"up":
			return "down"
		"down":
			return "up"
		"left":
			return "right"
		"right":
			return "left"

func movement_updatePath():
	host_removeSelfFromPreviousTileAsMoving()
	hostTile = currentPath.pop_front()

	#Append to unitMoving array on host.
	if len(currentPath) != 0:
		hostTile.unit_appendUnitMoving(self)
	hostTile.vision_updateInSightOf(vision, self, true, false)
	
	# Vision stuff
	if !isAlly:
		vision_hideOrShowEnemiesBasedOnTileVisibility()
	
	# When movement_updatePath is called, need to see if entering this new tile caused a collision
	if (movement_checkCollision()):
#		print("Collision detected, starting battle")
		return
	
	movement_evaluateRemainingTraveling()
#	print("In sight of values: " + str(prevTile.inSightOf))

func movement_evaluateRemainingTraveling():
	# Still remaining nodes to go
	if len(currentPath) > 0:
#		print("setting process true")
		set_process(true)
		movement_findDirection(currentPath[0])
		movement_placeAtStartOfPath(hostTile)
		movement_calcDistances()
		
	# Done traveling
	else:
#		print("Done traveling")
		isMoving = false
		host_removeSelfFromPreviousTileAsMoving()
		currentPath = []
		host_setUnitStationedOnHost()
		# Resets the position of the unit to be at the top of the tile
		directionMoving = "up"
		movement_placeAtStartOfPath(hostTile)

func movement_checkCollision():
	# Checks to see if theres conflicting units on the tile. Ally and enemy, or enemy and ally.
	if isAlly:
		if hostTile.unit_checkIfAnyUnitsOnThisTile("enemy") != false:
			# Battle is currently underway, 
			if hostTile.inBattle:
				rootRef.get_node("BattleScreen").refreshUnits(hostTile)
				# We don't want to trigger a new battle. If the unit ends here, it'll merge.
				# If it keeps moving, it'll just move past.
				return false
				
			if hostTile.enemyStationed != null:
				hostTile.battle_triggerBattleOnTile(self, hostTile.enemyStationed)
			else:
				# hostTile.unit_getClosestMovingUnit is not actually made, simply returning first found
				hostTile.battle_triggerBattleOnTile(self, hostTile.unit_getClosestMovingUnit())
			return true
	
	else:
		if hostTile.unit_checkIfAnyUnitsOnThisTile("ally") != false:
			if hostTile.inBattle:
				rootRef.get_node("BattleScreen").refreshUnits(hostTile)
				# We don't want to trigger a new battle. If the unit ends here, it'll merge.
				# If it keeps moving, it'll just move past.
				return false
				
			if hostTile.allyStationed != null:
				hostTile.battle_triggerBattleOnTile(hostTile.allyStationed, self)
			else:
				# hostTile.unit_getClosestMovingUnit is not actually made, simply returning first found
				hostTile.battle_triggerBattleOnTile(hostTile.unit_getClosestMovingUnit(), self)
			return true
				
func battle_placeAtBattlePositions():
	if isAlly:
		set_position(Vector2(hostTile.get_position()[0], hostTile.get_position()[1] - 75))
	else:
		set_position(Vector2(hostTile.get_position()[0] + 65, hostTile.get_position()[1] - 75))
				
func battle_enter():
	set_process(false)
	isMoving = false
	currentPath.push_front(hostTile)
	snared = true
	
#	directionMoving = "up"
#	movement_placeAtStartOfPath(hostTile)
	battle_placeAtBattlePositions()
	
	# Reset Hosttile's properties containing this unit.
	hostTile.unit_removeUnitCompletely(self)
	if isAlly:
		hostTile.allyStationed = self
	else:
		hostTile.enemyStationed = self
	
	
func battle_won():
	snared = false
	
	# Gives enemies their last movement order so that they may continue.
	if (len(currentPath) > 0):
		print("Giving the winning unit it's last movement order")
		set_process(true)
#		currentPath = pathToMove
		movement_updatePath()

	
func battle_lost():
	hostTile.unit_removeUnitCompletely(self)
	queue_free()

func vision_hideOrShowEnemiesBasedOnTileVisibility():
	# If the tile it's currently on is hidden, it should hide
	if !hostTile.currentlySeen:
		self.hide()
	
	# If the tile it's going to is NOT hidden, it should show
	if len(currentPath) != 0:
		if currentPath[0].currentlySeen:
			self.show()
	
func host_removeSelfFromPreviousTileAsMoving():
	if hostTile.unit_checkIfInMovingUnit(self):
		hostTile.unit_removeMovingUnit(self)
	
	
func host_setUnitStationedOnHost():
	# If this unit still has movement to go, do NOT merge
	if not currentPath.empty():
		return
	
	if isAlly:
		# Unit already exists on the tile, merge!
		if hostTile.allyStationed != null and hostTile.allyStationed != self:
			hostTile.allyStationed.stats_mergeWithOtherGroup(self)
		
		# No unit here, set self!
		else:
			hostTile.unit_setUnitStationed(self)
	else:
#		print("AM ENEMY")
		# Unit already exists on the tile, merge!
		if hostTile.enemyStationed != null and hostTile.enemyStationed != self:
#			print("OTHER ENEMY HERE, MERGINE")
			hostTile.enemyStationed.stats_mergeWithOtherGroup(self)
		
		# No unit here, set self!
		else:
#			print("OTHER ENEMY NOT HERE, IM STATIONED")
			hostTile.unit_setEnemyStationed(self)	

func movement_calcDistances():
	# This calculates how many units of distance need to be covered. The unit speed is used in the 
	# _process function, so it isn't needed here.
	distanceTotal = DIST_CONSTANT * numUnits
	distanceLeft = distanceTotal

func movement_moveUnitAlongPath(distanceMoved):
	match directionMoving:
		"up":
			self.set_position(Vector2(self.get_position()[0], self.get_position()[1] - distanceMoved))
		"down":
			self.set_position(Vector2(self.get_position()[0], self.get_position()[1] + distanceMoved))
		"right":
			self.set_position(Vector2(self.get_position()[0] + distanceMoved, self.get_position()[1]))
		"left":
			self.set_position(Vector2(self.get_position()[0] - distanceMoved, self.get_position()[1]))
	
func movement_placeAtStartOfPath(tile):
	var bufferChange = 0
	if !isAlly:
		bufferChange = 65
		
	match directionMoving:
		"up":
			self.set_position(Vector2(tile.get_position()[0] + bufferChange, tile.get_position()[1] - 75))
		"down":
			self.set_position(Vector2(tile.get_position()[0] + bufferChange, tile.get_position()[1] + 125))
		"right":
			self.set_position(Vector2(tile.get_position()[0] + 125, tile.get_position()[1] + bufferChange))
		"left":
			self.set_position(Vector2(tile.get_position()[0] - 75, tile.get_position()[1] + bufferChange))
		

func movement_findDirection(nextTile):
	if hostTile.row < nextTile.row:
		directionMoving = "down"
	elif hostTile.row > nextTile.row:
		directionMoving = "up"
	elif hostTile.col < nextTile.col:
		directionMoving = "right"
	elif hostTile.col > nextTile.col:
		directionMoving = "left"
	
func stats_createUnit(unitName, amount):
	match unitName:
		"Leader":
			unitTypes.append("Leader")
			unitRefs["Leader"] = leaderRef
			leaderRef.addFreshUnit(amount)
			numLeader += amount
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Leader.png")
			get_node("BG").set("texture", portrait)
			ui_setFormation("Leader")
		"Goblin":
			unitTypes.append("Goblin")
			unitRefs["Goblin"] = goblinRef
			goblinRef.addFreshUnit(amount)
			numGoblin += amount
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Goblin.png")
			get_node("BG").set("texture", portrait)
			ui_setFormation("Goblin")
			
	stats_updateTotalStats()
	numUnits = amount
	
	ui_showNumberOfUnitsTag()
	vision_checkHighest()
	
func stats_updateTotalStats():
	var tempCurHP = 0
	var tempMaxHP = 0
	var tempOffense = 0
	var tempSpeed = 0
	
	for ref in unitRefs:
		tempCurHP += unitRefs[ref].currentHP
		tempMaxHP += unitRefs[ref].maxHP
		tempOffense += unitRefs[ref].offense
		tempSpeed += unitRefs[ref].speed
	
	totalCurrentHealth = tempCurHP
	totalMaxHealth = tempMaxHP
	totalOffense = tempOffense
	totalSpeed = tempSpeed
	
	ui_showNumberOfUnitsTag()
	
#	if !isAlly:
#		hostTile.vision_checkIfSeen()

	
func vision_checkHighest():
	for item in unitTypes:
		match item:
			"Leader":
				vision_setNew(10)
			"Goblin":
				vision_setNew(1)
	
func vision_setNew(newVision):
	var updateVision = false
	
	if vision < newVision:
		vision = newVision
		updateVision = true
	
	if updateVision:
		vision_updateTilesVision()

func vision_updateTilesVision():
	if isAlly:
		hostTile.vision_updateInSightOf(vision, self, true, false)

func stats_mergeWithOtherGroup(newAddition):
	# Merge the units and the stats together
	stats_mergeUnits(newAddition)
	
	# Updates UI components
	ui_handleCurrentSelection(newAddition)
	
	#Removes sight of old unit
	hostTile.vision_updateInSightOf(vision, newAddition, false, false)
	
	# Updates vision
	vision_checkHighest()
	
	#Removes old unit.
	newAddition.queue_free()

func ui_handleCurrentSelection(newAddition):
	# If Host is selected,
	if get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").checkIfUnitSelected(self):
		#If new addition is NOT already selected
		if !get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").checkIfUnitSelected(newAddition):
			get_tree().get_root().get_node("Control/UnitHolder/UnitController").unselectUnit(self)
			get_tree().get_root().get_node("Control/UnitHolder/UnitController").unitClicked(self)
			
	#If Host is not selected, but moving unit is:
	if get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").checkIfUnitSelected(newAddition):
		get_tree().get_root().get_node("Control/UnitHolder/UnitController").unselectUnit(newAddition)
		get_tree().get_root().get_node("Control/UnitHolder/UnitController").unitClicked(self)

func stats_mergeUnits(newAddition):
	if newAddition.numLeader !=0:
		if numLeader == 0:
			unitTypes.append("Leader")
			unitRefs["Leader"] = leaderRef
			ui_setFormation("Leader")
		numLeader += newAddition.numLeader
		leaderRef.mergeUnit(newAddition.leaderRef)
	if newAddition.numGoblin !=0:
		if numGoblin == 0:
			unitTypes.append("Goblin")
			unitRefs["Goblin"] = goblinRef
			ui_setFormation("Goblin")
			
		numGoblin += newAddition.numGoblin
		goblinRef.mergeUnit(newAddition.goblinRef)
	numUnits += newAddition.numUnits
	stats_updateTotalStats()
	
	
func ui_showNumberOfUnitsTag():
	if numUnits > 1:
		get_node("NumUnits").show()
		get_node("NumUnits").set_text("x" + str(numUnits))
	else:
		get_node("NumUnits").hide()
		
func ui_setFormation(unit):
	# Ensures this unit type doesnt already have a position
	if !(unit in formation):
		match unit:
			"Leader":
				ui_setFormationClosestTo(1, unit)
			"Goblin":
				ui_setFormationClosestTo(0, unit)
			_:
				print("Unit.gd: we got a mis-match")
			
func ui_setFormationClosestTo(pos, unit):
	var heldPositions = [false, false, false, false, false, false]
	
	# Sets true for all positions that currently have a unit holding them
	for item in formation:
		heldPositions[formation[item]] = true
		
	# It's default position is open, place there and then return
	if heldPositions[pos] == false:
		formation[unit] = pos
		return
	
	# Default is taken, search first for a position in the same row, then other row for open position
	if pos in range(3):
		# Checks for free top row, then bottom row
		for i in range(6):
			if heldPositions[i] == false:
				formation[unit] = i
				return
		ui_placeInExtraFormation(unit)
	else:
		# Checks for free bottom row
		var index = 3
		while index < 6:
			if heldPositions[index] == false:
				formation[unit] = index
				return
			
		# Checks for free top row
		for i in range(3):
			if heldPositions[i] == false:
				formation[unit] = i
				return
		ui_placeInExtraFormation(unit)
		
func ui_placeInExtraFormation(unit):
	print("Unit.gd: All formation positions filled, placing in extra (does nothing right now)")



