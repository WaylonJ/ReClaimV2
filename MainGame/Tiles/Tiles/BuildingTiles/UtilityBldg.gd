extends "res://MainGame/Tiles/Tiles/BuildingTiles/_baseBuildTile.gd"
	
func _init():	
	# UI Values
	tileDescription = "    This does something, Utility is rather vague and can be a lot of things lmao"
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")
	
	# Building values
	buildingTime = 15
	buildingAlliance = "ally"
	vision = 3
	
	# Output values
	mana = null
	unit = null
	advanced = null
	research = 5
	unitName = null
	
	# Tier Upgrade / Output 
	tileUpgradeCosts = [
	[200, 50],
	[1000, 200],
	[4000, 500],
	[10000, 1500],
	[40000, 5000],
	[100000, 12500],]
	
	tileOutput = [
	[0, 0, 0, 5],
	[0, 0, 0, 10],
	[0, 0, 0, 15],
	[0, 0, 0, 20],
	[0, 0, 0, 25],
	[0, 0, 0, 30],]

