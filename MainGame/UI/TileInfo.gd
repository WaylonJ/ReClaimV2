extends HBoxContainer
	
var selectedTile = null
var selectedTileGroup = []
var previousTile = null
var mouseInTile = false
var baseTile = null
var Base_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")

var globalSelected = ""
var doubleClick = false


func _ready():
	show()
	set_process(true)
	get_node("../TileActions").hide()
	get_node("../NoSelection/ConstructionOptions").hide()
	get_node("../NoSelection").show()
	pass




	
func _input(event):
	if event is InputEventMouseButton and event.position[1] < 540:
		if event is InputEventMouseButton:
			if event.doubleclick:
				doubleClick = true
			
		if !event.is_pressed() and event.button_index == 1:
			globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
			
			# Click onto a completed building tile
			if mouseInTile and selectedTile.buildingComplete == true:
				# Checks to make sure nothing else is selected, or only other tiles are.
				
				if globalSelected == "tile" or globalSelected == "e":
					setGlobalSelected()
					
					# Single click, Shift not pressed
					if not Input.is_key_pressed(KEY_SHIFT):
						emptyTileGroup()
						
					# Checks to see if a building to construct is currently selected and prevents shiftClicks from doing anything
					if checkIfBuildingSelected():
						return
					# Append item to selectedTileGroup if group is empty or it's the same type
					appendIfNoTilesSelectedOrSimilarTiles()
					if doubleClick:
						if selectedTile.buildingName == "Base":
							return
						for tile in get_tree().get_nodes_in_group("Tiles"):
							appendIfSameTypeOfTile(tile)
						doubleClick = false
				
			# Click on the map, but not in a tile. Shift key is NOT held down
			elif not Input.is_key_pressed(KEY_SHIFT) and event.button_index == 1:
				doubleClick = false
				if globalSelected == "tile":
					get_tree().get_root().get_node("Control").unselectEverything()
				emptyTileGroup()
			else:
				doubleClick = false
	if Input.is_key_pressed(KEY_ESCAPE):
#		get_tree().get_root().get_node("Control").unselectEverything()
		emptyTileGroup()
		previousTile = null

func _mouseInTile(tile):
	mouseInTile = true
	selectedTile = tile

func _mouseOutOfTile(tile):
	mouseInTile = false
	selectedTile = null

func checkIfBuildingSelected():
	if get_node("../../../HiddenItems/HoveringBldgImage").selectedBldg != null:
		return true
	return false

func appendIfSameTypeOfTile(tile):
	if tile.get("buildingName") == selectedTile.get("buildingName") and selectedTile.get("buildingName") == selectedTileGroup[0].get("buildingName"):
		if not tile in selectedTileGroup:
			selectedTileGroup.append(tile)
			tile.get_node("TileHolder/Highlight").show()
			tile.set("selected", true)
			updateUI(tile)

func selectTile():
	selectedTileGroup.append(selectedTile)
	selectedTile.get_node("TileHolder/Highlight").show()
	selectedTile.set("selected", true)

func appendIfNoTilesSelectedOrSimilarTiles():
	if len(selectedTileGroup) == 0 or selectedTile.get("buildingName") == selectedTileGroup[0].get("buildingName"):
		# Ensures it isn't already selected and also not the baseTile
		if not selectedTile.get("selected") and selectedTile != baseTile:
			selectTile()
			
		#Calls UI update / sets previousTile
		updateUI(selectedTile)

func updateUI(tile):
	previousTile = selectedTile
	get_node("Description").set("text", tile.get("description"))
	get_node("Portrait").set("texture", tile.get("portrait"))
	get_node("Production/OutputBox").updateUI(tile)
	
	# Set the counter to number of selected tiles
	get_node("Portrait/NumSelected").setCounter(len(selectedTileGroup))
	openTileOptions(tile)
	
func getAllTiles():
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
		tile.connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		if tile.get("buildingName") == "Base":
			baseTile = tile
			
	get_node("Description").set("text", baseTile.get("description"))
	get_node("Portrait").set("texture", baseTile.get("portrait"))
	
func setGlobalSelected():
	get_tree().get_root().get_node("Control").selectSomething("tile")
	
func openTileOptions(tile):
	if tile == baseTile:
		get_node("../TileActions").hide()
		get_node("../NoSelection/ConstructionOptions").hide()
		get_node("../UpgradeMenu").hide()
		get_node("../../../HiddenItems/HoveringBldgImage").unselectEverything()
		if !(globalSelected == "unit"):
			get_node("../NoSelection/BasicOptions").show()
			get_node("../NoSelection").show()

	elif get_node("../UpgradeMenu").is_visible():
		pass
	else:
		get_node("../NoSelection").hide()
		get_node("../TileActions").show()
#		get_node("../UpgradeMenu").hide()
		
	
func emptyTileGroup():
	for item in selectedTileGroup:
		item.get_node("TileHolder/Highlight").hide()
		item.set("selected", false)
	selectedTileGroup = []
	updateUI(baseTile)
