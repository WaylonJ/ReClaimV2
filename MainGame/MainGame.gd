extends Control

var bigArr = []
var baseArr = []
var length = 0

var manaProduction = 0
var advancedProduction = 0
var researchProduction = 0

var manaSupply = 500
var advancedSupply = 10
var researchSupply = 50

var manaCap = 1000
var advancedCap = 500
var baseTile = null

var myTimer = 0.02

func _ready():
	startNewGame()
	print("Finished creating TileSet")
	
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



func makeBaseArray(Tile):
	var arr = []

	for row in range(15):
		arr.append([])
		for col in range(15):
			var myObj = Tile.instance()
			myObj.add_to_group("Tiles")
			myObj.rect_position = Vector2((-7 + row) * 175, (-7 + col) * 175)
			arr[row].append(myObj)
	
	for row in arr:
		for item in row:
			add_child(item)
	return arr
	
func startNewGame():
	var BaseTilePNG = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")
	var Tile = preload("Tiles/Tile.tscn")
	
	baseArr = makeBaseArray(Tile)
	length = len(baseArr) / 2
	
	baseTile = baseArr[length][length]
	baseTile.set("buildingName", "Base")
	baseTile.startBuilding()
	baseTile.createTile()
	baseTile.get_node("Background").set("texture", BaseTilePNG)
	
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
	
func checkCaps():
	if manaSupply > manaCap:
		manaSupply = manaCap
	if advancedSupply > advancedCap:
		advancedSupply = advancedCap
		
func updateUI():
	var mana = get_node("UI/BottomUI/RightSection/ResourceItems/Mana")
	var advanced = get_node("UI/BottomUI/RightSection/ResourceItems/Advanced")
	var research = get_node("UI/BottomUI/RightSection/ResourceItems/Research")
	
	mana.get_node("Label").set_text(str(floor(manaSupply)))
	advanced.get_node("Label").set_text(str(floor(advancedSupply)))
	research.get_node("Label").set_text(str(floor(researchSupply)))
	
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