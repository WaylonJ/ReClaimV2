extends Node

onready var rootRef = get_tree().get_root().get_node("Control")
onready var tileInfoRef = rootRef.get_node("UI/BottomUI/MiddleSection/TileInfo")
onready var databaseRef = preload("res://MainGame/Tiles/TileDatabase.gd").new()
var sellCost = []
var outputAmount = []

var sellMultiplier = 0.5
#var databaseRef = 11

func _ready():
	pass # Replace with function body.

func sellTile(tileGroup):
	var index = 0
	var tile
	while not tileGroup.empty():
		tile = tileGroup[0]
		sellCost = databaseRef.getSellInfo(tile.buildingName, tile.buildingTier)

		
		# Update global income
		outputAmount = databaseRef.getOutputInfo(tile.buildingName, tile.buildingTier)
		rootRef.updateTotalProduction(outputAmount[0] * -1, outputAmount[1] * -1, outputAmount[3] * -1)
		
		# Refund supply based on tileCost
		index = 1
		while index < tile.buildingTier:
			sellCost = databaseRef.getSellInfo(tile.buildingName, tile.buildingTier - index)
			rootRef.refundCost(sellCost[0] * sellMultiplier, sellCost[1] * sellMultiplier)
			index += 1
		# 
		tile.resetTile()
		tileInfoRef.removeTile(tile)
		tileInfoRef.selectBaseTile()
