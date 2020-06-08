#extends Control
extends "res://MainGame/UnitController.gd"

func _ready():
	allyUnit = false
	set_process(true)

func _input(event):
	pass
	
func makeTestEnemy(tile):
	var enemyTilePosition = tile.get_position()
	var unit = preload("Units/EnemyUnit.tscn")
	var enemy = unit.instance()
	
	enemy.add_to_group("Enemies")
	enemy.setTile(tile)
	 
	tile.setEnemyStationed(enemy)
	enemy.createUnit("baseEnemy", 10)
	enemy.set_position(Vector2(enemyTilePosition[0] + 65, enemyTilePosition[1] - 75))
	add_child(enemy)

