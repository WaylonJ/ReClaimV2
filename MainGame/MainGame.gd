extends Control

# Constants 
const BASE_ROWS = 50
const BASE_COLS = 50

# Other variables
var bigArr = []
var startingArray = []
var length = 0

var baseTile = null

var myTimer = 0.02

# Variables that control player resources
var manaProduction = 0
var advancedProduction = 0
var researchProduction = 0

var manaSupply = 500
var advancedSupply = 100
var researchSupply = 100

var manaCap = 1000
var advancedCap = 500

# Global Variable to keep track of which component is selected by the player
var selectedName = "e"

# Variables to hold scripts from other places
var linkCreator = load("res://MainGame/GenerateTileLinks.gd").new()
var unitMovement = load("res://MainGame/Units/UnitMovement.gd").new()

func _ready():
	print("Started!")
	startNewGame()
	
	# Calls functions in other scripts here to ensure nodes they use are already initialized
	get_node("UI/HiddenItems/HoveringBldgImage").call("getAllTiles")
	get_node("UI/BottomUI/MiddleSection/TileInfo").call("getAllTiles")

	# Initializes the unitMovement script
	get_node("UnitHolder").add_child(unitMovement)
	unitMovement.makeCostGraph(startingArray)

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

	# Establishes Base tile
	makeBaseTile()

	# Make leader unit
	get_node("UnitHolder/UnitController").makeLeaderUnit(baseTile)

	populateBoard()
	# Make test enemy unit
#	var testEnemyTile = startingArray[length][length - 1]
#	get_node("UnitHolder/EnemyController").makeTestEnemy(testEnemyTile)
	

func populateBoard():
	makeEnemyPositions()


# This should probably all be in a new script
func makeEnemyPositions():
	# Will attempt to create tiles / 5 locations to be enemy Fortification locations.
	# Requirements: Not within 4 tiles of another enemy. Not within 3 tiles of the Player Base
	var remainingEnemies = BASE_COLS * BASE_ROWS / 5
	var tile
	while remainingEnemies != 0:
		tile = selectRandomTiles()
		attemptToCreateEnemyLocation(tile)
		remainingEnemies -= 1

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
	baseTile.startBuilding()
	baseTile.createTile()
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

func checkBuildable(tile):
	match tile:
		"ManaPool":
			if manaSupply > 100:
				manaSupply -= 100
				return true

		"ResourceBldg":
			if manaSupply > 150:
				manaSupply -= 150
				return true

		"MilitaryBldg":
			if manaSupply > 125 and advancedSupply > 25:
				manaSupply -= 125
				advancedSupply -= 25
				return true

		"UtilityBldg":
			if manaSupply > 200 and advancedSupply > 50:
				manaSupply -= 200
				advancedSupply -= 50
				return true
		_:
			print("MainGame.gd: I've no idea how this triggered")
	
	return false
	
func checkIfSomethingSelected():
	return selectedName

func selectSomething(name):
	selectedName = name
	
func unselectEverything():
	selectedName = "e"