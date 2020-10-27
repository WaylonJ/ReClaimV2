extends Node

var tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_EnemyTest.png")
var tileDescription = "    This building creates basic enemy troops, similar to the current Military bldg " + \
	"They will be constantly stationed and idk if this will ever be seen"

var buildingTime = 0
var vision = 0
var buildingAlliance = "enemy"
var output = []

var mana = 0
var unit = 0
var advanced = 0
var research = 0

var unitName = null
	

func _ready():
	pass # Replace with function body.

func getConstructionInfo():
	return [
	tileDescription,
	tilePortrait,
	buildingTime,
	buildingAlliance,
	vision,
	[mana, unit, advanced, research],
	unitName
	]
	
