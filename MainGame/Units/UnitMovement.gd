extends Node

var tileHovered = null
var path = null
var costGraph = []
var costQueue

var shiftHeld = false

onready var rootRef = get_tree().get_root().get_node("Control")

func _ready():
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
		tile.get_node("TileHolder/Background").connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.get_node("TileHolder/ShowBattleButton").connect("mouse_entered", self, "_mouseInTile", [tile])
		tile.get_node("TileHolder/Background").connect("mouse_exited", self, "_mouseOutOfTile", [tile])
		tile.get_node("TileHolder/ShowBattleButton").connect("mouse_exited", self, "_mouseOutOfTile", [tile])

func _mouseInTile(tile):
	tileHovered = tile
#	print(tile)

func _mouseOutOfTile(tile):
	tileHovered = null

func _input(event):
	if Input.is_key_pressed(KEY_SHIFT):
		shiftHeld = true
	else:
		shiftHeld = false
	# Checks for a right click
	if event is InputEventMouseButton and event.button_index == 2 and !event.is_pressed():
		# Checks to make sure a unit is selected and cursor is over a tile
		if get_tree().get_root().get_node("Control").selectedName == "allyUnit" and tileHovered != null:
			# If you right click on a tile, but move the cursor too much, this cancels the movement order. 
			# Prevents accidental movement orders when scrolling around
			if rootRef.get_node("Camera2D").cameraDragged:
				return
			
			for unit in get_tree().get_root().get_node("Control/UnitHolder/UnitController").selectedUnits:
				handleMovementLogic(unit)

func handleMovementLogic(unit):
	# Can't move, end here
	if unit.snared:
		return
	
	var replaceCurrentPath = true
	
	if shiftHeld:
		if unit.isMoving:
			# Append path to end of current path
			path = findShortestPath(unit.currentPath.pop_back(), tileHovered)
			replaceCurrentPath = false
		else:
			# Append path to empty current path
			path = findShortestPath(unit.hostTile, tileHovered)
	else:
		if unit.isMoving:
			# Replace current path with new path
			path = findShortestPath(unit.hostTile, tileHovered)
		else:
			# Append path to empty current path
			path = findShortestPath(unit.hostTile, tileHovered)
#			print("In unit movement, path: " + str(path))
	
	unit.appendPath(path, replaceCurrentPath)

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
		return costQueue
		
	var current = null
	var done = false
	
	costQueue = [[[origin], 0]]
	
	costGraph[origin.row][origin.col] = true

	
	while !done:
		current = costQueue.pop_front()
		done = checkNeighboursAndInsertInCostQueue(current, target)
		
#	print("Unit movement: " + str(costQueue))
	resetCostGraph()
	return costQueue
		
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
			
func autoMoveUnit(unit, destination):
	findShortestPath(unit.hostTile, destination)
	path = costQueue
#	print("Automove triggered, this is path: " + str(path))
	unit.appendPath(path, true)

func findDistanceBetweenTwoTiles(tile1, tile2):
	findShortestPath(tile1, tile2)
	return costQueue.size()
