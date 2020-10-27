extends Node

# Ally Bldgs
var MANA_BLDG = load("res://MainGame/Tiles/Tiles/BuildingTiles/ManaPool.gd").new()
var GOBLIN_BLDG = load("res://MainGame/Tiles/Tiles/BuildingTiles/GoblinHutBldg.gd").new()
var ADV_RESOURCE_BLDG = load("res://MainGame/Tiles/Tiles/BuildingTiles/AdvResourceBldg.gd").new()
var UTILITY_BLDG = load("res://MainGame/Tiles/Tiles/BuildingTiles/UtilityBldg.gd").new()
var BASE_BLDG = load("res://MainGame/Tiles/Tiles/BuildingTiles/BaseBldg.gd").new()

# Enemy Bldgs
var ENEMY_BASIC_BLDG = load("res://MainGame/Tiles/Tiles/EnemyTiles/EnemySpawnerBasic.gd").new()

func _ready():
	pass # Replace with function body.

func getBldg(name):
	match name:
		"Base":
			return BASE_BLDG
		"ManaPoolBldg":
			return MANA_BLDG
		"AdvResourceBldg":
			return ADV_RESOURCE_BLDG
		"GoblinBldg":
			return GOBLIN_BLDG
		"UtilityBldg":
			return UTILITY_BLDG
		"EnemyTest":
			return ENEMY_BASIC_BLDG
		_:
			print("getConstructionInfo - TileDatabase: Invalid bldg name")
			return

func getConstructionInfo(name):
	return getBldg(name).getConstructionInfo()

func getUpgradeInfo(name, tier):
	return getBldg(name).getUpgradeInfo(tier)
			
func getSellInfo(name, tier):
	tier -= 1
	return getBldg(name).getUpgradeInfo(tier)

func getOutputInfo(name, tier):
	tier -= 1
	return getBldg(name).getOutputInfo(tier)
