extends "res://MainGame/Tiles/Tiles/BuildingTiles/_baseBuildTile.gd"
	
func _init():	
	# UI Values
	tileDescription = "    The Center of Control for your operations. Provides basic resources along with " + \
	"access towards various upgrades."
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
	
	# Building values
	buildingTime = 0
	buildingAlliance = "ally"
	vision = 2
	
	# Output values
	mana = 10
	unit = null
	advanced = 0
	research = 0
	unitName = null
	

