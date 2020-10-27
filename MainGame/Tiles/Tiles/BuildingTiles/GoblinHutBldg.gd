extends "res://MainGame/Tiles/Tiles/BuildingTiles/_baseBuildTile.gd"
	
func _init():	
	# UI Values
	tileDescription = "    This building creates troops for your army. It must be supplied with enough " + \
	"supplies to continue this production."
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
	
	# Building values
	buildingTime = 1
	buildingAlliance = "ally"
	vision = 2
	
	# Output values
	mana = null
	unit = 0.5
	advanced = null
	research = 0
	unitName = "Goblin"
	
	# Tier Upgrade / Output 
	tileUpgradeCosts = [
	[125, 25],
	[300, 100],
	[1000, 300],
	[5000, 1000],
	[20000, 5000],
	[75000, 15000],]
	
	tileOutput = [
	[0, 0, 0.5, 0],
	[0, 0, 0.25, 0],
	[0, 0, 0.125, 0],
	[0, 0, 0.0625, 0],
	[0, 0, 0.03125, 0],
	[0, 0, 0.015625, 0],]

