extends TextureRect

var selectedBldg = null
var tempBG = null
var currentTile = null
var shiftHeld = false

var Base_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")
var Blank_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Blank.png")
var Mana_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Mana.png")
var Military_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_MilitaryBldg.png")
var Resource_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_ResourceBldg.png")
var Utility_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_UtilityBldg.png")

onready var tileInfoRef = get_node("../../BottomUI/MiddleSection/TileInfo")

func _ready():
#	print(self.get_path())
	pass

func getAllTiles():
	
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	var buttonList = get_tree().get_nodes_in_group("ConstructionButtons")
	for button in buttonList:
		button.connect("pressed", self, "_on_thisButton_pressed", [button])
	

	for tile in tiles:
		tile.connect("mouse_entered", self, "_on_mouse_entered_highlight", [tile])
		tile.connect("mouse_exited", self, "_on_mouse_exited_highlight", [tile])
		
#	var backButton = get_tree().get_root().get_node("UI/BottomUI/MiddleSection/NoSelection/ConstructionOptions/BotRow/BackButton")
#	backButton.connect("pressed", self, "_on_BackButton_pressed")
#	print(get_tree().get_nodes_in_group("Tiles"))

func _on_mouse_entered_highlight(tile):
	if selectedBldg != null:
		# Save the tile's current BG here
		tempBG = tile.get_node("TileHolder/Background").get("texture")
		
		if tempBG == Blank_Tile:
#			var emptyPrompt = tile.emptyPrompt
#			print(emptyPrompt)
			
			currentTile = tile
			# Set the tile's BG to be the BG of whatever is selected.
			match selectedBldg:
				"ResourceBldg":
					tile.get_node("TileHolder/Background").set("texture", Resource_Tile)
				"MilitaryBldg":
					tile.get_node("TileHolder/Background").set("texture", Military_Tile)
				"UtilityBldg":
					tile.get_node("TileHolder/Background").set("texture", Utility_Tile)
				"ManaPool":
					tile.get_node("TileHolder/Background").set("texture", Mana_Tile)
				_:
					pass
				
	else:
		pass
#		print("Selected bldg null")
	
func _on_mouse_exited_highlight(tile):
	if tempBG != null:
		tile.get_node("TileHolder/Background").set("texture", tempBG)
		tempBG = null
#	currentTile = null

func _on_thisButton_pressed(button):
	selectedBldg = button.get_name()
#	print("Selected bldg is now: " + str(selectedBldg))

func _on_BackButton_pressed():
	unselectEverything()
	
func _input(event):
	# We have a tile selected, we've clicked a tile on the board
	if event is InputEventMouseButton and selectedBldg != null and !event.is_pressed() and event.button_index == 1:
		# Click on map, not tile
		if tempBG == null and not Input.is_key_pressed(KEY_SHIFT):
			unselectEverything()
			
		# Click on non-empty tile
		elif tempBG != Blank_Tile and not Input.is_key_pressed(KEY_SHIFT):
			tempBG = null
			unselectEverything()
		
		# Ensures we're over a tile that doesn't have a building already
		elif tempBG == Blank_Tile:
			if attemptToCreateBuilding(selectedBldg):
				# Shift key allows multiple constructions at once
				if not Input.is_key_pressed(KEY_SHIFT):
					selectedBldg = null
					hideHighlightBorder()
				
#				print("NULLING")
				tempBG = null
			else:
				print("HoveringBldgImage: Building attempt failed")
			
	if Input.is_key_pressed(KEY_ESCAPE):
		if tempBG != null:
			unselectEverything()

func attemptToCreateBuilding(bldg):
	#CHECK RESOURCE COST AND THE LIKE HERE
	if get_tree().get_root().get_node("Control").checkBuildable(bldg):
		createTile()
		
		return true
#	if true:
#		createTile()
		

func createTile():
	currentTile.set("buildingName", selectedBldg)
	currentTile.startBuilding()
	currentTile.createTile()
	tempBG = null
	
	# If shift not held down, revert to base tile. Otherwise don't change ui
	if not Input.is_key_pressed(KEY_SHIFT):
		tileInfoRef.selectBaseTile()
#	tileInfoRef.updateUI()
	
	
func unselectEverything():
	selectedBldg = null
	
	if tempBG != null:
		currentTile.get_node("TileHolder/Background").set("texture", tempBG)
		tempBG = null
	hideHighlightBorder()

func hideHighlightBorder():
	get_tree().get_root().get_node("Control/UI/HiddenItems/SelectedHighlight").hide()
