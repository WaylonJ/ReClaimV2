extends Node

const BASE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
const MANA_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
const MILITARY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
const RESOURCE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
const UTILITY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")
const ENEMY_TEST_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_EnemyTest.png")

const BASE_DESCRIPTION = "    The Center of Control for your operations. Provides basic resources along with " + \
	"access towards various upgrades."
const MANAPOOL_DESCRIPTION = "    This tile provides a steady supply of Mana to your CoC. It may be upgraded to " + \
	"increase the amount of mana generated, or even to provide healing towards troops stationed here."
const MILITARY_DESCRIPTION = "    This building creates troops for your army. It must be supplied with enough " + \
	"supplies to continue this production."
const UTILITY_DESCRIPTION = "    This does something, Utility is rather vague and can be a lot of things lmao"
const RESOURCE_DESCRIPTION = "    This building creates some arbitrary resource. Maybe it also consumes other " + \
	"resources to do so. idk"
const ENEMY_TEST = "    This building creates basic enemy troops, similar to the current Military bldg " + \
	"They will be constantly stationed and idk if this will ever be seen."

var description = ""
var portrait = ""
var buildingTime = 0
var vision = 0
var buildingAlliance = "ally"
var output = []

var mana = 0
var unit = 0
var advanced = 0
var research = 0

var unitName = null

const ManaPoolUpgradeCosts = [
	[100, 0],
	[250, 0],
	[750, 10],
	[2500, 50],
	[10000, 200],
	[50000, 600],]

const ManaPoolOutput = [
	[5, 0, 0, 0],
	[10, 0, 0, 0],
	[20, 0, 0, 0],
	[40, 0, 0, 0],
	[80, 0, 0, 0],
	[160, 0, 0, 0],]

const GoblinUpgradeCosts = [
	[125, 25],
	[300, 100],
	[1000, 300],
	[5000, 1000],
	[20000, 5000],
	[75000, 15000],]
	
const GoblinOutput = [
	[0, 0, 0.5, 0],
	[0, 0, 0.25, 0],
	[0, 0, 0.125, 0],
	[0, 0, 0.0625, 0],
	[0, 0, 0.03125, 0],
	[0, 0, 0.015625, 0],]
	
const ResourceUpgradeCosts = [
	[150, 0],
	[500, 0],
	[3000, 50],
	[15000, 200],
	[80000, 600],
	[250000, 2000],]

const ResourceOutput = [
	[-2, 1, 0, 0],
	[-4, 2, 0, 0],
	[-8, 4, 0, 0],
	[-16, 8, 0, 0],
	[-32, 16, 0, 0],
	[-64, 32, 0, 0],]
	
const UtilityUpgradeCosts = [
	[200, 50],
	[1000, 200],
	[4000, 500],
	[10000, 1500],
	[40000, 5000],
	[100000, 12500],]
	
const UtilityOutput = [
	[0, 0, 0, 5],
	[0, 0, 0, 10],
	[0, 0, 0, 15],
	[0, 0, 0, 20],
	[0, 0, 0, 25],
	[0, 0, 0, 30],]

func _ready():
	pass # Replace with function body.


func getConstructionInfo(name):
	match name:
		"Base":
			description = BASE_DESCRIPTION
			portrait = BASE_PORTRAIT
			buildingTime = 0
			buildingAlliance = "ally"
			vision = 2
			
			mana = 10
			unit = null
			advanced = 0
			research = 0
			
			unitName = null
			
		"ManaPool":
			description = MANAPOOL_DESCRIPTION
			portrait = MANA_PORTRAIT
			buildingTime = 0.5
			buildingAlliance = "ally"
			vision = 1
			
			mana = 5
			unit = null
			advanced = null
			research = null
			
			unitName = null
			
		"ResourceBldg":
			description = RESOURCE_DESCRIPTION
			portrait = RESOURCE_PORTRAIT
			buildingTime = 0.5
			buildingAlliance = "ally"
			vision = 1
			
			mana = -2
			unit = null
			advanced = 1
			research = null
			
			unitName = null
			
		"MilitaryBldg":
			description = MILITARY_DESCRIPTION
			portrait = MILITARY_PORTRAIT
			buildingTime = 1
			buildingAlliance = "ally"
			vision = 2
			
			mana = null
			unit = 0.5
			advanced = null
			research = 0
			
			unitName = "Goblin"
			
		"UtilityBldg":
			description = UTILITY_DESCRIPTION
			portrait = UTILITY_PORTRAIT
			buildingTime = 15
			buildingAlliance = "ally"
			vision = 3
			
			mana = null
			unit = null
			advanced = null
			research = 5
			
			unitName = null
			
		"EnemyTest":
			description = ENEMY_TEST
			portrait = ENEMY_TEST_PORTRAIT
			buildingTime = 0.1
			buildingAlliance = "enemy"
			
			mana = null
			unit = 1
			advanced = null
			research = null
			
			unitName = "baseEnemy"
		_:
			print("TileDatabase: Invalid bldg name")
			
	return [
	description,
	portrait,
	buildingTime,
	buildingAlliance,
	vision,
	[mana, unit, advanced, research],
	unitName
	]

func getUpgradeInfo(tileName, tier):
	match tileName:
		"ManaPool":
			return ManaPoolUpgradeCosts[tier]

		"ResourceBldg":
			return ResourceUpgradeCosts[tier]

			
		"MilitaryBldg":
			return GoblinUpgradeCosts[tier]

			
		"UtilityBldg":
			return UtilityUpgradeCosts[tier]
			
		_:
			print("TileDatabase: Invalid bldg name")
			
func getSellInfo(tileName, tier):
	match tileName:
		"ManaPool":
			return ManaPoolUpgradeCosts[tier]

		"ResourceBldg":
			return ResourceUpgradeCosts[tier]

			
		"MilitaryBldg":
			return GoblinUpgradeCosts[tier]

			
		"UtilityBldg":
			return UtilityUpgradeCosts[tier]
			
		_:
			print("TileDatabase: Invalid bldg name")

func getOutputInfo(tileName, tier):
	tier -= 1
	match tileName:
		"ManaPool":
			return ManaPoolOutput[tier]

		"ResourceBldg":
			return ResourceOutput[tier]

			
		"MilitaryBldg":
			return GoblinOutput[tier]

			
		"UtilityBldg":
			return UtilityOutput[tier]
			
		_:
			print("TileDatabase: Invalid bldg name")
