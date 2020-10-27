extends "res://MainGame/Tiles/Tiles/EnemyTiles/_baseEnemyTile.gd"

func _init():	
	# UI Values
	tileDescription = "    This building creates basic enemy troops, similar to the current Military bldg " + \
	"They will be constantly stationed and idk if this will ever be seen"
	tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_EnemyTest.png")
	
	# Building values
	buildingTime = 0.1
	buildingAlliance = "enemy"
	vision = 1
	
	# Output values
	mana = null
	unit = .25
	advanced = null
	research = null
	unitName = "baseEnemy"


