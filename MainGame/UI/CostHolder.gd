extends HBoxContainer

onready var databaseRef = get_tree().get_root().get_node("Control").tileDatabase
var upgradeCost = []

func _ready():
	pass 


func setCosts(tile, numberOfTileSelected):
#	print("costholder: " + str(databaseRef))
	upgradeCost = databaseRef.getUpgradeInfo(tile.buildingName, tile.buildingTier)
	setManaCost(upgradeCost[0])
	setAdvancedCost(upgradeCost[1])

func setManaCost(amount):
	get_node("./ManaOutput/Label").text = str(amount)
	
func setAdvancedCost(amount):
	get_node("./AdvancedOutput/Label").text = str(amount)
