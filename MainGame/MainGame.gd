extends Control

# Constants (50)
const BASE_ROWS = 10
const BASE_COLS = 10

# Other variables
var bigArr = []
var startingArray = []
var length = 0
var randTileRow = null
var randTileCol = null

var baseTile = null

var myTimer = 0.02

# Variables that control player resources
var manaProduction = 0
var advancedProduction = 0
var researchProduction = 0

var manaSupply = 750
var advancedSupply = 100
var researchSupply = 100

var manaCap = 1000
var advancedCap = 500

# Global Variable to keep track of which component is selected by the player
var selectedName = "e"

# Variables to hold scripts from other places
var linkCreator = load("res://MainGame/GenerateTileLinks.gd").new()
var unitMovement = load("res://MainGame/Units/UnitMovement.gd").new()
var tileDatabase = load("res://MainGame/Tiles/TileDatabase.gd").new()

var testTime = 0
var testTime2 = 0

func _ready():
	print("Started!")
	startNewGame()
	
	# Calls functions in other scripts here to ensure nodes they use are already initialized
	get_node("UI/HiddenItems/HoveringBldgImage").call("getAllTiles")
	get_node("UI/BottomUI/MiddleSection/TileInfo").call("getAllTiles")


	
	set_process(true)
	
func _process(delta):
	if myTimer <= 0:
		myTimer = 0.05 + myTimer
		manaSupply += manaProduction / 20.0
		advancedSupply += advancedProduction / 20.0
		researchSupply += researchProduction / 20.0
	else:
		myTimer -= delta
	
	checkCaps()
	updateUI()

func startNewGame():
	# Creates the starting array
	startingArray = makeBaseArray()
	
	# Makes the links between each tile
	get_node("LinkHolder").add_child(linkCreator)
	linkCreator.createLinks(startingArray)
	
	# Initializes the unitMovement script
	get_node("UnitHolder").add_child(unitMovement)
	unitMovement.makeCostGraph(startingArray)
	
	

	# Establishes Base tile
	makeBaseTile()

	# Make leader unit
	get_node("UnitHolder/UnitController").makeLeaderUnit(baseTile)

	populateBoard()
	# Make test enemy unit
	var testEnemyTile = startingArray[length][length - 1]
	get_node("UnitHolder/EnemyController").makeTestEnemy(testEnemyTile)
#
	testEnemyTile = startingArray[length][length + 1]
	get_node("UnitHolder/EnemyController").makeTestEnemy(testEnemyTile)
	
	setTileBorders(startingArray)
	

func populateBoard():
#	makeEnemyBases()
	makeEnemyUnits()

func setTileBorders(array):	
	for row in array:
		for item in row:
			if item.connections[0]:
				item.get_node("Walls/TopOpen").show()
			else:
				item.get_node("Walls/TopClosed").show()
			if item.connections[1]:
				item.get_node("Walls/RightOpen").show()
			else:
				item.get_node("Walls/RightClosed").show()
			if item.connections[2]:
				item.get_node("Walls/BotOpen").show()
			else:
				item.get_node("Walls/BotClosed").show()
			if item.connections[3]:
				item.get_node("Walls/LeftOpen").show()
			else:
				item.get_node("Walls/LeftClosed").show()

# This should probably all be in a new script
func makeEnemyBases():
	# Will attempt to create tiles / 5 locations to be enemy Fortification locations.
	# Requirements: Not within 4 tiles of another enemy. Not within 3 tiles of the Player Base
#	var createEnemyAttempts = BASE_COLS * BASE_ROWS / 5
	var createEnemyAttempts = 1
	var tile
	while createEnemyAttempts != 0:
		tile = selectRandomTiles()
		if checkForAllyOrEnemyTilesNearby(tile, 3, true):
			makeEnemyBase(tile)
		createEnemyAttempts -= 1

func makeEnemyUnits():
	# Will attempt to create tiles / 2 locations to be enemy unit locations.
	# Requirements: Not within 3 tiles of the Player Base
#	var createEnemyAttempts = BASE_COLS * BASE_ROWS / 2
	var createEnemyAttempts = 1
	var tile
	var validTile
	
	while createEnemyAttempts != 0:
		# Checks if an enemy unit is already stationed here or if this is an enemy base
		validTile = false
		while not validTile:
			tile = selectRandomTiles()
			if tile.get("enemyStationed") == null and tile.get("buildingAlliance") == "neutral":
				validTile = true
		
		if checkForBase(tile, 4, true):
			makeEnemyUnit(tile)
			createEnemyAttempts -= 1
		
func makeEnemyUnit(tile):
	get_node("UnitHolder/EnemyController").makeBaseEnemy(tile)

func selectRandomTiles():
	# Gets a random row and column. Returns the tile found at that location.
	randomize()
	randTileRow = randi() % BASE_ROWS
	randTileCol = randi() % BASE_COLS
	
	return startingArray[randTileRow][randTileCol]
	
func checkForBase(tile, toCheck, nothingFound):
	# This function goes up to 'toCheck' distance away from the original tile searching for
	# ally tiles. If it finds them, it'll return false, telling the parent that there 
	# already exists a created building nearby. Causing the parent's while loop to continue.
	if nothingFound == false or tile.get("buildingAlliance") == "ally":
		# This new placement is too close to an existing ally or enemy building. 
		return false
		
	# Need to make sure no ally tiles are within 3 tiles
	if toCheck != 0:
		if tile.connections[0] == true and tile.aboveTile != null:
			nothingFound = checkForBase(tile.aboveTile, toCheck - 1, nothingFound)
		if tile.connections[1] == true and tile.rightTile != null:
			nothingFound = checkForBase(tile.rightTile, toCheck - 1, nothingFound)
		if tile.connections[2] == true and tile.belowTile != null:
			nothingFound = checkForBase(tile.belowTile, toCheck - 1, nothingFound)
		if tile.connections[3] == true and tile.leftTile != null:
			nothingFound = checkForBase(tile.leftTile, toCheck - 1, nothingFound)
			
	return nothingFound
	
func checkForAllyOrEnemyTilesNearby(tile, toCheck, nothingFound):
	# This function goes up to 'toCheck' distance away from the original tile searching for
	# ally or enemy tiles. If it finds them, it'll return false, telling the parent that there 
	# already exists a created building nearby. Causing the parent's while loop to continue.
	if tile.get("buildingAlliance") != "neutral" or nothingFound == false:
		# This new placement is too close to an existing ally or enemy building. 
		return false
	
	# Need to make sure no enemy bases or ally tiles are within 3 tiles
	if toCheck != 0:
		if tile.connections[0] == true and tile.aboveTile != null:
			nothingFound = checkForAllyOrEnemyTilesNearby(tile.aboveTile, toCheck - 1, nothingFound)
		if tile.connections[1] == true and tile.rightTile != null:
			nothingFound = checkForAllyOrEnemyTilesNearby(tile.rightTile, toCheck - 1, nothingFound)
		if tile.connections[2] == true and tile.belowTile != null:
			nothingFound = checkForAllyOrEnemyTilesNearby(tile.belowTile, toCheck - 1, nothingFound)
		if tile.connections[3] == true and tile.leftTile != null:
			nothingFound = checkForAllyOrEnemyTilesNearby(tile.leftTile, toCheck - 1, nothingFound)
			
	return nothingFound
	
func makeEnemyBase(tile):
	var enemyTilePNG = preload("res://MainGame/Tiles/Resources/PH_Tile_EnemyBase.png")
	tile.set("buildingName", "EnemyTest")
	tile.basic_findDistanceFromBase(baseTile)
	tile.bldg_startBuilding()
	tile.bldg_createTile()
	tile.get_node("TileHolder/Background").set("texture", enemyTilePNG)
	

func makeBaseArray():
	var tile = preload("Tiles/Tile.tscn")
	var arr = []

	for row in range(BASE_ROWS):
		arr.append([])
		for col in range(BASE_COLS):
			var myObj = tile.instance()
			myObj.row = row
			myObj.col = col
			myObj.connections = [false, false, false, false]
			myObj.add_to_group("Tiles")
			# Constants here decide the spacing between each  tile
			myObj.rect_position = Vector2(((-1 * BASE_COLS / 2) + col) * 300, ((-1 * BASE_ROWS / 2) + row) * 300)
			arr[row].append(myObj)
	
	for row in arr:
		for item in row:
			add_child(item)
	return arr

func makeBaseTile():
	var BaseTilePNG = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")
	length = len(startingArray) / 2
	
	baseTile = startingArray[length][length]
	baseTile.set("buildingName", "Base")
	baseTile.bldg_startBuilding()
	baseTile.bldg_createTile()
	baseTile.get_node("TileHolder/Background").set("texture", BaseTilePNG)
	
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
	get_node("UI/BottomUI/MiddleSection/TileInfo/Production/OutputBox").updateUI(baseTile)

func updateUI():
	var mana = get_node("UI/BottomUI/RightSection/ResourceItems/Mana")
	var advanced = get_node("UI/BottomUI/RightSection/ResourceItems/Advanced")
	var research = get_node("UI/BottomUI/RightSection/ResourceItems/Research")
	
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
	
func refundCost(manaCost, advancedCost):
	manaSupply += manaCost
	advancedSupply += advancedCost
	checkCaps()
	
func checkIfSomethingSelected():
	return selectedName

func selectSomething(name):
	selectedName = name
	
func unselectEverything():
	selectedName = "e"
