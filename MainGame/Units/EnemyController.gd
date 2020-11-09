#extends Control
extends "res://MainGame/Units/UnitController.gd"

onready var rootRef = get_tree().get_root().get_node("Control")

#

func _ready():
	allyUnit = false
	
func makeTestEnemy(tile):
	var enemyTilePosition = tile.get_position()
	var unit = preload("EnemyUnit.tscn")
	var enemy = unit.instance()
	
	enemy.add_to_group("Enemies")
	enemy.hostTile = tile
	 
	tile.unit_setEnemyStationed(enemy)
	enemy.stats_createUnit("baseEnemy", 10)
	enemy.set_position(Vector2(enemyTilePosition[0] + 65, enemyTilePosition[1] - 75))
	add_child(enemy)

func makeBaseEnemy(tile):
	var enemyTilePosition = tile.get_position()
	var unit = preload("EnemyUnit.tscn")
	var enemy = unit.instance()
	
	
	
	enemy.add_to_group("Enemies")
	enemy.hostTile = tile
	enemy.stats_createUnit("baseEnemy", determineSizeOfGroup(tile))
	enemy.set_position(Vector2(enemyTilePosition[0] + 65, enemyTilePosition[1] - 75))
	enemy.stats_updateTotalStats()
	
	tile.unit_setEnemyStationed(enemy)
	tile.vision_checkIfSeen(tile)
	
	add_child(enemy)

func determineSizeOfGroup(tile):
	var distanceFromBase = rootRef.unitMovement.findDistanceBetweenTwoTiles(tile, rootRef.baseTile)
	var totalAmount
	
	totalAmount = distanceFromBase * 5
	totalAmount = ceil(pow(totalAmount, 1.2))
	
	return totalAmount
