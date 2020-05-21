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
	generateUnitRefs()

func _process(delta):
	distanceLeft -= delta * totalSpeed
	distanceMovedSinceLastTick += (delta * totalSpeed) / numUnits
	
	# Progress unit towards next tile visually
	if distanceMovedSinceLastTick >= 1:
		moveUnitAlongPath(distanceMovedSinceLastTick * 10)
		distanceMovedSinceLastTick -= 1
	
	# Units has reached its destination
	if distanceLeft < 0:
		set_process(false)
		
		if isAlly:
			hostTile.updateInSightOf(vision, self, false, false)
		hostTile = currentPath[0]
#		removeSelfFromInSightOf()
#		hostTile.updateInSightOf(vision, self, true, false)
#		print("In sight of values: " + str(hostTile.inSightOf))
		updatePath()

func generateUnitRefs():
	leaderRef = leaderScript.new()
	add_child(leaderRef)
	
	goblinRef = goblinScript.new()
	add_child(goblinRef)

func appendPath(newPath, replacing):
	pathToMove.append(newPath)
	if currentPath.empty():
		currentPath = pathToMove.pop_front()
		updatePath()
	# Righ click for movement, with no shift
	elif replacing:
		returnUnitToHostTile()
		
func returnUnitToHostTile():
	directionMoving = setOppositeDirection()
	distanceLeft = (DIST_CONSTANT * numUnits) - distanceLeft

func setOppositeDirection():
	match directionMoving:
		"up":
			return "down"
		"down":
			return "up"
		"left":
			return "right"
		"right":
			return "left"

func updatePath():
	# Still remaining nodes to go
	if len(currentPath) > 1:
		prevTile = currentPath.pop_front()
		removeSelfFromPreviousTile()

#		setUnitStationedOnHost()
		set_process(true)
		findDirection(currentPath[0])
		placeAtStartOfPath(prevTile)
		calcDistances()
		
	# Done traveling
	else:
		currentPath = []
		setUnitStationedOnHost()
		# Resets the position of the unit to be at the top of the tile
		directionMoving = "up"
		placeAtStartOfPath(hostTile)
	
	hostTile.updateInSightOf(vision, self, true, false)
	print("In sight of values: " + str(hostTile.inSightOf))

func removeSelfFromInSightOf():
	prevTile.updateInSightOf(vision, self, false, false)

func removeSelfFromPreviousTile():
	if isAlly:
		if prevTile.unitStationed == self:
			prevTile.unitStationed = null
	else:
		if prevTile.enemyStationed == self:
			prevTile.enemyStationed = null
	
func setUnitStationedOnHost():
	if isAlly:
		# Unit already exists on the tile, merge!
		if hostTile.unitStationed != null and hostTile.unitStationed != self:
			hostTile.unitStationed.mergeWithOtherGroup(self)
		
		# No unit here, set self!
		else:
			hostTile.setUnitStationed(self)
	else:
		# Unit already exists on the tile, merge!
		if hostTile.enemyStationed != null and hostTile.enemyStationed != self:
			hostTile.enemyStationed.mergeWithOtherGroup(self)
		
		# No unit here, set self!
		else:
			hostTile.setEnemyStationed(self)	

func calcDistances():
	distanceTotal = DIST_CONSTANT * numUnits
	distanceLeft = distanceTotal

func moveUnitAlongPath(distanceMoved):
	match directionMoving:
		"up":
			self.set_position(Vector2(self.get_position()[0], self.get_position()[1] - distanceMoved))
		"down":
			self.set_position(Vector2(self.get_position()[0], self.get_position()[1] + distanceMoved))
		"right":
			self.set_position(Vector2(self.get_position()[0] + distanceMoved, self.get_position()[1]))
		"left":
			self.set_position(Vector2(self.get_position()[0] - distanceMoved, self.get_position()[1]))
	
func placeAtStartOfPath(tile):
	match directionMoving:
		"up":
			self.set_position(Vector2(tile.get_position()[0], tile.get_position()[1] - 75))
		"down":
			self.set_position(Vector2(tile.get_position()[0], tile.get_position()[1] + 125))
		"right":
			self.set_position(Vector2(tile.get_position()[0] + 125, tile.get_position()[1]))
		"left":
			self.set_position(Vector2(tile.get_position()[0] - 75, tile.get_position()[1]))

func findDirection(nextTile):
	if prevTile.row < nextTile.row:
		directionMoving = "down"
	elif prevTile.row > nextTile.row:
		directionMoving = "up"
	elif prevTile.col < nextTile.col:
		directionMoving = "right"
	elif prevTile.col > nextTile.col:
		directionMoving = "left"

func setTile(tile):
	hostTile = tile
	
func createUnit(unitName, amount):
	match unitName:
		"Leader":
			unitTypes.append("Leader")
			unitRefs["Leader"] = leaderRef
			leaderRef.addFreshUnit(amount)
			numLeader += amount
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Leader.png")
			get_node("BG").set("texture", portrait)
			setFormation("Leader")
		"Goblin":
			unitTypes.append("Goblin")
			unitRefs["Goblin"] = goblinRef
			goblinRef.addFreshUnit(amount)
			numGoblin += amount
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Goblin.png")
			get_node("BG").set("texture", portrait)
			setFormation("Goblin")
			
	updateTotalStats()
	numUnits = amount
	if numUnits < 2:
		get_node("NumUnits").hide()
	checkHighestVision()
	
func updateTotalStats():
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
	
	showNumberOfUnitsTag()
	
#	if !isAlly:
#		hostTile.checkIfSeen()

	
func checkHighestVision():
	for item in unitTypes:
		match item:
			"Leader":
				setVision(4)
			"Goblin":
				setVision(1)
	
func setVision(newVision):
	var updateVision = false
	
	if vision < newVision:
		vision = newVision
		updateVision = true
	
	if updateVision:
		updateTilesVision()

func updateTilesVision():
	if isAlly:
		hostTile.updateInSightOf(vision, self, true, false)

func mergeWithOtherGroup(newAddition):
	# Merge the units and the stats together
	mergeUnits(newAddition)

	if isAlly:
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
		
		#Removes sight of old unit
		hostTile.updateInSightOf(vision, newAddition, false, false)
		
		#Removes old unit.
		newAddition.queue_free()
		
		# Updates vision
		checkHighestVision()

func mergeUnits(newAddition):
	if newAddition.numLeader !=0:
		if numLeader == 0:
			unitTypes.append("Leader")
			unitRefs["Leader"] = leaderRef
			setFormation("Leader")
		numLeader += newAddition.numLeader
		leaderRef.mergeUnit(newAddition.leaderRef)
	if newAddition.numGoblin !=0:
		if numGoblin == 0:
			unitTypes.append("Goblin")
			unitRefs["Goblin"] = goblinRef
			setFormation("Goblin")
			
		numGoblin += newAddition.numGoblin
		goblinRef.mergeUnit(newAddition.goblinRef)
	numUnits += newAddition.numUnits
	updateTotalStats()
	
	
func showNumberOfUnitsTag():
	if numUnits > 1:
		get_node("NumUnits").show()
		get_node("NumUnits").set_text("x" + str(numUnits))
	else:
		get_node("NumUnits").hide()
		
func setFormation(unit):
	# Ensures this unit type doesnt already have a position
	if !(unit in formation):
		match unit:
			"Leader":
				setFormationClosestTo(1, unit)
			"Goblin":
				setFormationClosestTo(0, unit)
			_:
				print("Unit.gd: we got a mis-match")
			
func setFormationClosestTo(pos, unit):
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
		placeInExtraFormation(unit)
	else:
		# Checks for free bottom row
		var index = 3
		for index in range(6):
			if heldPositions[index] == false:
				formation[unit] = index
				return
		# Checks for free top row
		for i in range(3):
			if heldPositions[i] == false:
				formation[unit] = i
				return
		placeInExtraFormation(unit)
		
func placeInExtraFormation(unit):
	print("Unit.gd: All formation positions filled, placing in extra (does nothing right now)")

func getRef(unitName):
	match unitName:
		"Leader":
			return leaderRef
		"Goblin":
			return goblinRef



