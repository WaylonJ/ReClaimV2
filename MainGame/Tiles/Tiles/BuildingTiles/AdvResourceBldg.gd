extends "res://MainGame/Tiles/Tiles/BuildingTiles/_baseBuildTile.gd"
	
func _init():	
	# UI Values
	tileDescription = "    This building creates some arbitrary resource. Maybe it also consumes other " + \
	"resources to do so. idk"
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
	
	# Building values
	buildingTime = 0.5
	buildingAlliance = "ally"
	vision = 1
	
	# Output values
	mana = -2
	unit = null
	advanced = 1
	research = null
	unitName = null
	
	# Tier Upgrade / Output 
	tileUpgradeCosts = [
	[150, 0],
	[500, 0],
	[3000, 50],
	[15000, 200],
	[80000, 600],
	[250000, 2000],]
	
	tileOutput = [
	[-2, 1, 0, 0],
	[-4, 2, 0, 0],
	[-8, 4, 0, 0],
	[-16, 8, 0, 0],
	[-32, 16, 0, 0],
	[-64, 32, 0, 0],]

