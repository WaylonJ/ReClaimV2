extends Node

var tileHovered = null
var path = null

func _ready():
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
		tile.connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		

func _mouseInTile(tile):
	tileHovered = tile
	pass

func _mouseOutOfTile(tile):
	tileHovered = null
	pass
	
func _input(event):
	# Checks for a single click on the map
	if event is InputEventMouseButton and event.button_index == 2 and !event.is_pressed():
		# Checks to make sure a unit is selected and cursor is over a tile
		if get_tree().get_root().get_node("Control").selectedName == "unit" and tileHovered != null:
			print(tileHovered.buildingName)
#			for unit in get_tree().get_root().get_node("Control/UnitHolder/UnitController").selectedUnits:
#				path = findShortestPath(unit.hostTile, tileHovered)
#				sendUnitOnPath(unit, path)
				
#			if Input.mouse

func findShortestPath(origin, target):
	var costQueue = [origin]
	var current = null
	var index = 0
	
	var newCost = 0
	var newLoc = null
	
	while true:
		current = costQueue.pop_front()
		
		index = 0
		for connection in current.connections:
			if connection == true:
				#WORKING HERE
				# When making links between tiles, give each tile a variable that holds all tiles it is connected to
				# That way its a lot easier to look through the links between tiles rather than doing a bunch of calculations
				# 
				pass
#				newCost, newLoc = findCostOfNewConnection(current.row, current.col, index, target.row, target.col)
#				costQueue.insert(addToCostQueue(newCost, costQueue))
		
		pass
	
func findCostOfNewConnection(curRow, curCol, direction, targetRow, targetCol):
	match direction:
		0:
			curRow -= 1
		1:
			curCol += 1
		2:
			curRow += 1
		3:
			curCol -= 1
	
#	return (abs(targetRow - curRow) + abs(targetCol - curCol)), [curRow, curCol]
	
func addToCostQueue():
	pass
	
	
	
func sendUnitOnPath(unit, path):
	pass