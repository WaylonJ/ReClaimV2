extends HBoxContainer

var selectedTile = null
var selectedTileGroup = []
var previousTile = null
var mouseInTile = false
var baseTile = null
var Base_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")
var infoOnlyTiles = ["EnemyTest"]
var unselectableTiles = ["Blank"]

var globalSelected = ""
var doubleClick = false
var ignoreClick = false

onready var rootRef = get_tree().get_root().get_node("Control")
onready var hoverBldgRef = rootRef.get_node("UI/HiddenItems/HoveringBldgImage")

func _ready():
	show()
	set_process(true)
	get_node("../TileActions").hide()
	get_node("../NoSelection/ConstructionOptions").hide()
	get_node("../NoSelection").show()
	
func _input(event):
	if event is InputEventMouseButton and event.position[1] < 540:
		if ignoreClick:
			ignoreClick = false
			return
		if event is InputEventMouseButton:
			if event.doubleclick:
				doubleClick = true
			
		# Left click
		if !event.is_pressed() and event.button_index == 1:
			print("mouse click")
			print(mouseInTile)
			globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
			
			# Click onto a completed building tile
			if mouseInTile and selectedTile.buildingName != "Blank":
				print(selectedTile.buildingName)
				
				# Checks to make sure nothing else is selected, or only other tiles are.
				if globalSelected == "tile" or globalSelected == "e":
					setGlobalSelected()
						
					# Single click, Shift not pressed
					if not Input.is_key_pressed(KEY_SHIFT):
						emptyTileGroup()
#						updateUI()
					
					# Append item to selectedTileGroup if group is empty or it's the same type
					appendIfNoTilesSelectedOrSimilarTiles()
					print("Selected tiles: " + str(selectedTileGroup))
					if doubleClick:
						if selectedTile.buildingName == "Base":
							return
						for tile in get_tree().get_nodes_in_group("Tiles"):
							selectedTile = tile
							appendIfNoTilesSelectedOrSimilarTiles()
#							appendIfSameTypeOfTile(tile)
						doubleClick = false
			
			# Click on the map, but not in a tile. Shift key is NOT held down
			elif not Input.is_key_pressed(KEY_SHIFT) and event.button_index == 1:
				print("here1")
				doubleClick = false
				if globalSelected == "tile":
					get_tree().get_root().get_node("Control").unselectEverything()
				emptyTileGroup()
				selectBaseTile()
			elif not Input.is_key_pressed(KEY_SHIFT) and event.button_index == 1 and mouseInTile:
				pass
			else:
				doubleClick = false
	if Input.is_key_pressed(KEY_ESCAPE):
		emptyTileGroup()
		previousTile = null

func _mouseInTile(tile):
#	print("Tile nanme:" + str(tile.buildingName) + ", " + str(tile))
	mouseInTile = true
	selectedTile = tile

func _mouseOutOfTile(tile):
#	print("out of tile")
	mouseInTile = false
	selectedTile = null
	doubleClick = false

func appendIfSameTypeOfTile(tile):
	if tile.get("buildingName") == selectedTile.get("buildingName") and selectedTile.get("buildingName") == selectedTileGroup[0].get("buildingName"):
		if not tile in selectedTileGroup:
			selectedTileGroup.append(tile)
			tile.get_node("TileHolder/Highlight").show()
			tile.set("selected", true)
			
			updateUI()

func selectTile():
	selectedTileGroup.append(selectedTile)
	selectedTile.get_node("TileHolder/Highlight").show()
	selectedTile.set("selected", true)

func appendIfNoTilesSelectedOrSimilarTiles():
	if len(selectedTileGroup) == 0 or (selectedTile.get("buildingName") == selectedTileGroup[0].get("buildingName") and selectedTile.get("buildingTier") == selectedTileGroup[0].get("buildingTier")):
		# If clicks on empty tile, acts as if on map.
		for tile in unselectableTiles:
			if selectedTile.buildingName == tile:
				selectedTile = baseTile
		
		# Ensures it isn't already selected and also not the baseTile
		if !(selectedTile.get("selected")) and selectedTile != baseTile:
			selectTile()
			updateUI()
		elif selectedTile == baseTile:
			print("here2")
			selectBaseTile()
		
		#Calls UI update / sets previousTile
		

func checkIfInfoOnly():
	for invalidName in infoOnlyTiles:
		if invalidName == selectedTile.buildingName:
			return true
	return false

func updateUI():
	previousTile = selectedTile
	if selectedTile == null:
		selectedTile = baseTile
	get_node("Description").set("text", selectedTile.get("description"))
	get_node("Portrait").set("texture", selectedTile.get("portrait"))
	get_node("Production/OutputBox").updateUI(selectedTileGroup)
	
	# Set the counter to number of selected tiles
	get_node("Portrait/NumSelected").setCounter(len(selectedTileGroup))
	#if not Input.is_key_pressed(KEY_SHIFT):
	openTileOptions()
	

	
func selectBaseTile():
	selectedTile = null
	selectedTileGroup = [baseTile]
	updateUI()
	
func getAllTiles():
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
#		tile.connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.get_node("TileHolder/Background").connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.get_node("TileHolder/ShowBattleButton").connect("mouse_entered", self, "_mouseInTile", [tile])
#		tile.connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		tile.get_node("TileHolder/Background").connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		tile.get_node("TileHolder/ShowBattleButton").connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		
		if tile.get("buildingName") == "Base":
			baseTile = tile
			
	get_node("Description").set("text", baseTile.get("description"))
	get_node("Portrait").set("texture", baseTile.get("portrait"))
	
func setGlobalSelected():
	get_tree().get_root().get_node("Control").selectSomething("tile")
	
func openTileOptions():
	resetUI()
	if selectedTile == baseTile:
		if !(globalSelected == "allyUnit"):
			get_node("../NoSelection/BasicOptions").show()
			get_node("../NoSelection").show()
	elif checkIfInfoOnly():
		get_node("../NoSelection").hide()
		pass
	elif get_node("../UpgradeMenu").is_visible():
		pass
	else:
		get_node("../NoSelection").hide()
		get_node("../TileActions").show()
	
func resetUI():
	
	get_node("../TileActions").hide()
	get_node("../UpgradeMenu").hide()
	get_node("../NoSelection/ConstructionOptions").hide()
	get_node("../../../HiddenItems/HoveringBldgImage").hideHighlightBorder()
#	get_node("../../../HiddenItems/HoveringBldgImage").unselectEverything()

func emptyTileGroup():
	for item in selectedTileGroup:
		item.get_node("TileHolder/Highlight").hide()
		item.set("selected", false)
	selectedTileGroup = []
	
func removeTile(tile):
	tile.get_node("TileHolder/Highlight").hide()
	tile.set("selected", false)
	var index = 0
	for currTile in selectedTileGroup:
		if currTile == tile:
			selectedTileGroup.remove(index)
		index += 1

func resetOutputBox():
	if selectedTileGroup.size() == 0:
		selectBaseTile()
	get_node("Production/OutputBox").updateUI(selectedTileGroup)
	get_node("Portrait/NumSelected").setCounter(len(selectedTileGroup))
	
