extends Node

onready var rootRef = get_tree().get_root().get_node("Control")
onready var tileInfoRef = rootRef.get_node("UI/BottomUI/MiddleSection/TileInfo")
onready var databaseRef = preload("res://MainGame/Tiles/TileDatabase.gd").new()
var upgradeCost = []
var newOutput = []
var removeThese = []
#var databaseRef = 11

func _ready():
	pass # Replace with function body.

func upgradeTile(tileGroup):
	removeThese = []
	tileInfoRef = rootRef.get_node("UI/BottomUI/MiddleSection/TileInfo")

	for tile in tileGroup:
		upgradeCost = databaseRef.getUpgradeInfo(tile.buildingName, tile.buildingTier)
		
		# Check if the supply is available, subtracts it if true
		if not rootRef.checkBuildable(upgradeCost[0], upgradeCost[1]):
			break

		# 
		updateTileWithUpgrade(tile)
	
	removeAllUpgraded(tileGroup.size())
	
	pass

func updateTileWithUpgrade(tile):
	# Update tier
	tile.buildingTier += 1
	
	# Update image
	# TBD 
	
	# Remove past values from production
	removePastValuesFromProduction(tile)
	
	# Update tile Output
	newOutput = databaseRef.getOutputInfo(tile.buildingName, tile.buildingTier)
	tile.updateOutput(newOutput[0], newOutput[1], newOutput[2], newOutput[3])
	
	# Add new values to production
	rootRef.updateTotalProduction(tile.outputMana, tile.outputAdvanced, tile.outputResearch)
	removeThese.append(tile)
	
func removePastValuesFromProduction(tile):
	var newMana = tile.outputMana
	var newAdvanced = tile.outputAdvanced
	var newResearch = tile.outputResearch
	
	if newMana != null:
		newMana *= -1
	if newAdvanced != null:
		newAdvanced *= -1
	if newResearch != null:
		newResearch *= -1

	rootRef.updateTotalProduction(newMana, newAdvanced, newResearch)
	
func removeAllUpgraded(originalAmount):
	if removeThese.size() == originalAmount:
		tileInfoRef.resetOutputBox()
		return
	
	for tile in removeThese:
		# Deselect from selectedTiles
		tileInfoRef.removeTile(tile)
		
	tileInfoRef.resetOutputBox()
