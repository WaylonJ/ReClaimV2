extends Node

var tileHovered = null
var path = null
var costGraph = []
var costQueue

func _ready():
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
		tile.connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.connect("mouse_exited", self, "_mouseOutOfTile", [tile])

func _mouseInTile(tile):
	tileHovered = tile

func _mouseOutOfTile(tile):
	tileHovered = null

func _input(event):
	# Checks for a right click
	if event is InputEventMouseButton and event.button_index == 2 and !event.is_pressed():
		# Checks to make sure a unit is selected and cursor is over a tile
		if get_tree().get_root().get_node("Control").selectedName == "allyUnit" and tileHovered != null:
#			print("Unit Movement, selected units: " + str(get_tree().get_root().get_node("Control/UnitHolder/UnitController").selectedUnits))
			for unit in get_tree().get_root().get_node("Control/UnitHolder/UnitController").selectedUnits:
				if !(unit.snared):
					findShortestPath(unit.hostTile, tileHovered)
					path = costQueue
					unit.appendPath(path, true)

func sendUnitOnPath(unit, path):
	unit.moveTo(path)
	pass

func printPath(path):
	var home = path[0]
	var row = home.row
	var col = home.col
	for tile in path:
		printraw(" ||R: " + str(tile.col - col) + ",D: " + str(tile.row - row))
		
func findShortestPath(origin, target):
	# In case tile selected is the one the unit is stationed at
	if origin == target:
		costQueue = [origin]
		return
		
	var current = null
	var done = false
	
	costQueue = [[[origin], 0]]
	costGraph[origin.row][origin.col] = true

	
	while !done:
		current = costQueue.pop_front()
		done = checkNeighboursAndInsertInCostQueue(current, target)
		
#	print("Unit movement: " + str(costQueue))
	resetCostGraph()
	return
		
func checkNeighboursAndInsertInCostQueue(item, target):
	var connectionIndex = 0
	var directions = []
	var distance
	var totalCost
	var tileArr = item[0].duplicate(true)
	var curCost = len(tileArr)
	var tile = tileArr[curCost - 1]
	
	for connection in tile.connections:
		tileArr = item[0].duplicate(true)
		if connection == true:
			match connectionIndex:
				0:
					if tile.aboveTile != null:
						# Ensures this is the first visit here
						if costGraph[tile.row - 1][tile.col] == false:
							costGraph[tile.row - 1][tile.col] = true
							tileArr.append(tile.aboveTile)
							distance = findDistance(target, tile.row - 1, tile.col)
							if distance == 0:
								costQueue = tileArr
								return true
							else:
								totalCost = curCost + distance
								insertIntoCostQueue([tileArr, totalCost])
				1:
					if tile.rightTile != null:
						# Ensures this is the first visit here
						if costGraph[tile.row][tile.col + 1] == false:
							costGraph[tile.row][tile.col + 1] = true
							tileArr.append(tile.rightTile)
							distance = findDistance(target, tile.row, tile.col + 1)
							if distance == 0:
								costQueue = tileArr
								return true
							else:
								totalCost = curCost + distance
								insertIntoCostQueue([tileArr, totalCost])
				2:
					if tile.belowTile != null:
						# Ensures this is the first visit here
						if costGraph[tile.row + 1][tile.col] == false:
							costGraph[tile.row + 1][tile.col] = true
							tileArr.append(tile.belowTile)
							distance = findDistance(target, tile.row + 1, tile.col)
							if distance == 0:
								costQueue = tileArr
								return true
							else:
								totalCost = curCost + distance
								insertIntoCostQueue([tileArr, totalCost])
				3:
					if tile.leftTile != null:
						# Ensures this is the first visit here
						if costGraph[tile.row][tile.col - 1] == false:
							costGraph[tile.row][tile.col - 1] = true
							tileArr.append(tile.leftTile)
							distance = findDistance(target, tile.row, tile.col - 1)
							if distance == 0:
								costQueue = tileArr
								return true
							else:
								totalCost = curCost + distance
								insertIntoCostQueue([tileArr, totalCost])
							
				_:
					print("UnitMovement.gd: invalid match statement")
			
			
		connectionIndex += 1
	return false
	
func makeCostGraph(array):
	var index = 0
	for row in array:
		costGraph.append([])
		for col in row:
			costGraph[index].append(false)
		index += 1
		
func resetCostGraph():
	var rowCounter = 0
	var colCounter = 0
	for row in costGraph:
		colCounter = 0
		for item in row:
			costGraph[rowCounter][colCounter] = false
			colCounter += 1
		rowCounter += 1
		
func findDistance(target, row, col):
	var distance = abs(target.row - row) + abs(target.col - col)
	return distance
	
func insertIntoCostQueue(newItem):
	var newCost = newItem[1]
	var counter = 0
	var itemCost
	if costQueue.empty():
		costQueue.append(newItem)
	else:
		for item in costQueue:
			itemCost = item[1]
			if newCost <= itemCost:
				costQueue.insert(counter, newItem)
				return
			counter += 1
		costQueue.append(newItem)
			
	
	
