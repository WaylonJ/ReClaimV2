extends TextureRect

var selectedTile = null
var tempBG = null
var currentTile = null
var shiftHeld = false

var Base_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")
var Blank_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Blank.png")
var Mana_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Mana.png")
var Military_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_MilitaryBldg.png")
var Resource_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_ResourceBldg.png")
var Utility_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_UtilityBldg.png")

func _ready():
	pass

func _get_all_tiles():
	
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
	if selectedTile != null:
		# Save the tile's current BG here
		tempBG = tile.get_node("Background").get("texture")
		
		if tempBG == Blank_Tile:
			var emptyPrompt = tile.emptyPrompt
			print(emptyPrompt)
			
			currentTile = tile
			# Set the tile's BG to be the BG of whatever is selected.
			match selectedTile:
				"ResourceBldg":
					tile.get_node("Background").set("texture", Resource_Tile)
				"MilitaryBldg":
					tile.get_node("Background").set("texture", Military_Tile)
				"UtilityBldg":
					tile.get_node("Background").set("texture", Utility_Tile)
				_:
					pass
				
	
func _on_mouse_exited_highlight(tile):
	if tempBG != null:
		tile.get_node("Background").set("texture", tempBG)
#	currentTile = null

func _on_thisButton_pressed(button):
	selectedTile = button.get_name()

func _on_BackButton_pressed():
	unselectEverything()
	
func _input(event):
	# We have a tile selected, we've clicked a tile on the board
	if event is InputEventMouseButton and selectedTile != null:
		if tempBG == null and not Input.is_key_pressed(KEY_SHIFT):
			unselectEverything()
		# Ensures we're over a tile that doesn't have a building already
		elif tempBG == Blank_Tile:
			# Shift key allows multiple constructions at once
			if not Input.is_key_pressed(KEY_SHIFT):
				selectedTile = null
				hide_highlight_border()
			tempBG = null
			
	if Input.is_key_pressed(KEY_ESCAPE):
		if tempBG != null:
			unselectEverything()

func unselectEverything():
	selectedTile = null
	
	if tempBG != null:
		currentTile.get_node("Background").set("texture", tempBG)
		tempBG = null
	hide_highlight_border()

func hide_highlight_border():
	get_tree().get_root().get_node("Control/UI/HiddenItems/SelectedHighlight").hide()