extends Node

var tilePortrait = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
var tileDescription = "    BASE DEFAULT DESCRIPTION"

var buildingTime = 0
var vision = 0
var buildingAlliance = "ally"
var output = []

var mana = 0
var unit = 0
var advanced = 0
var research = 0

var unitName = null

var tileUpgradeCosts = [
	[0, 0],
	[0, 0],
	[0, 0],
	[0, 0],
	[0, 0],
	[0, 0],]

var tileOutput = [
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0],]
	

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

func getUpgradeInfo(tier):
	return tileUpgradeCosts[tier]
	
func getSellInfo(tier):
	return tileUpgradeCosts[tier - 1]

func getOutputInfo(tier):
	return tileOutput[tier - 1]
