extends "res://MainGame/Tiles/Tiles/BuildingTiles/_baseBuildTile.gd"
	
func _init():	
	# UI Values
	tileDescription = "    This tile provides a steady supply of Mana to your CoC. It may be upgraded to " + \
	"increase the amount of mana generated, or even to provide healing towards troops stationed here."
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
	
	# Building values
	buildingTime = 0.5
	buildingAlliance = "ally"
	vision = 1
	
	# Output values
	mana = 5
	unit = null
	advanced = null
	research = null
	unitName = null
	
	# Tier Upgrade / Output 
	tileUpgradeCosts = [
	[100, 0],
	[250, 0],
	[750, 10],
	[2500, 50],
	[10000, 200],
	[50000, 600],]
	
	tileOutput = [
	[5, 0, 0, 0],
	[10, 0, 0, 0],
	[20, 0, 0, 0],
	[40, 0, 0, 0],
	[80, 0, 0, 0],
	[160, 0, 0, 0],]

