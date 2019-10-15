extends Button

var portrait

var numLeader = 0
var numBaseEnemy = 0
var numUnits = 0

var unitTypes = []

var currentHealth = 0
var maxHealth = 0
var offense = 0
var defense = 0
var speed = 0

var hostTile = null
var prevTile = null

var pathToMove = []
var currentPath = []

var distanceTotal
var distanceLeft
var distanceMovedSinceLastTick = 0
var directionMoving

var vision = 0

var formation = {}

func _ready():
	self.connect("mouse_entered", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseEntered", [self])
	self.connect("mouse_exited", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseExited")
	set_process(false)
#	self.add_to_group("Units")
	pass # Replace with function body.

func _process(delta):
	distanceLeft -= delta * speed
	distanceMovedSinceLastTick += (delta * speed) / numUnits
	
	# Progress unit towards next tile visually
	if distanceMovedSinceLastTick >= 1:
		moveUnitAlongPath(2)
		distanceMovedSinceLastTick -= 1
	
	# Units has reached its destination
	if distanceLeft < 0:
		set_process(false)
		hostTile = currentPath[0]
		removeSelfFromInSightOf()
		hostTile.updateInSightOf(vision, self, true)
		updatePath()

func appendPath(newPath):
	pathToMove.append(newPath)
	if currentPath.empty():
		currentPath = pathToMove.pop_front()
		updatePath()

func updatePath():
	if len(currentPath) > 1:
		prevTile = currentPath.pop_front()
		prevTile.unitStationed = null
		set_process(true)
		findDirection(currentPath[0])
		placeAtStartOfPath(prevTile)
		calcDistances()

	else:
		updateHostTile()
		# Resets the position of the unit to be at the top of the tile
		directionMoving = "up"
		placeAtStartOfPath(hostTile)

func removeSelfFromInSightOf():
	prevTile.updateInSightOf(vision, self, false)

func updateHostTile():
	hostTile = currentPath.pop_front()
	if hostTile.unitStationed != null and hostTile.unitStationed != self:
		hostTile.unitStationed.mergeWithOtherGroup(self)
	else:
		hostTile.unitStationed = self
#		hostTile.updateInSightOf(vision, self, true)

func calcDistances():
	distanceTotal = 10 * numUnits
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
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Leader.png")
			get_node("BG").set("texture", portrait)
			numLeader += amount
			offense = amount * 20
			defense = amount * 20
			speed = amount * 10
			currentHealth = amount * 100
			maxHealth = amount * 100
			unitTypes.append("Leader")
			setFormation("Leader")
		"baseEnemy":
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_BasicEnemy.png")
			get_node("BG").set("texture", portrait)
			numBaseEnemy += amount
			offense = amount * 7
			defense = amount * 7
			speed = amount * 12
			currentHealth = amount * 29
			maxHealth = amount * 29
			unitTypes.append("baseEnemy")
			setFormation("baseEnemy")
	
	numUnits = amount
	if numUnits < 2:
		get_node("NumUnits").hide()
	checkHighestVision()
	
func checkHighestVision():
	for item in unitTypes:
		match item:
			"Leader":
				setVision(2)
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
	hostTile.updateInSightOf(vision, self, true)

func mergeWithOtherGroup(newAddition):
	# Merge the units and the stats together
	mergeUnits(newAddition)
	mergeStats(newAddition)
	
	# If there is a single unit, hide tag. Otherwise show number of units.
	showNumberOfUnitsTag()

	# Once a new troop moves into a tile, if that tile's troops are selected, this appends them on the UI.
	if get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").checkIfUnitSelected(self):
		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").displayUnitGroup(newAddition)
		
	# Remove old unit
	newAddition.queue_free()
	checkHighestVision()

func mergeUnits(newAddition):
	if newAddition.numLeader !=0:
		if numLeader == 0:
			unitTypes.append("Leader")
			setFormation("Leader")
		numLeader += newAddition.numLeader
	numUnits += newAddition.numUnits

func mergeStats(newAddition):
	offense += newAddition.offense
	defense += newAddition.defense
	speed += newAddition.speed
	currentHealth += newAddition.currentHealth
	maxHealth += newAddition.maxHealth
	
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
			"baseEnemy":
				setFormationClosestTo(1, unit)
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
