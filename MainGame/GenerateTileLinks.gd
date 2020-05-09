extends Node

#Weights for deciding on the connections between tiles
var upWeight = 0.19
var rightWeight = 0.44
var downWeight = 0.75
var leftWeight = 1.00

#Constants that determine how many connections are made for each tile
const ONE_CONN_CHANCE = 0.1
const TWO_CONN_CHANCE = 0.6
const THREE_CONN_CHANCE = 0.9
const FOUR_CONN_CHANCE = 1.0

var arr = null
var touched = null
var arrLength = 0

func createLinks(array):
	arr = array
	arrLength = len(array)

	# Makes the base tile always be connected to the 4 adjacent tiles
	setHomeConnections()

	# Make connections for the rest of the array.
	generateConnections(len(arr), len(arr[0]), len(arr) / 2 - 1, len(arr[0]) / 2 + 1, 1)
	
	# Ensure no nodes are left as 'islands' without a way to get to the homeNode
	fixIslands()
	
func setHomeConnections():
	var home = arr[arrLength / 2][arrLength / 2]
	
	home.connections = [true, true, true, true]
	
	makeLink(home, "up")
	makeLink(home, "right")
	makeLink(home, "down")
	makeLink(home, "left")

func makeLink(tileOrigin, direction):
	var link = preload("Links/Link.tscn")
	var newLink = link.instance()
	
	var originPos = tileOrigin.get_position()
	var originRow = tileOrigin.row
	var originCol = tileOrigin.col
	
	var tileDestination = null

	add_child(newLink)
	match direction:
		"up":
			# Tells the origin tile there is a connection
			tileOrigin.connections[0] = true
			
			# Ensures the above tile exists and tell's the tile there is a connection
			if originRow != 0:
				tileDestination = arr[originRow - 1][originCol]
				tileDestination.connections[2] = true
				tileOrigin.aboveTile = tileDestination
				tileDestination.belowTile = tileOrigin
			
			# Sets the position of the Link and makes it appear
			newLink.set_position(Vector2(originPos[0] + 52, originPos[1] - 173)) 
			newLink.get_node("VerticalLink").show()
		"right":
			tileOrigin.connections[1] = true
			
			if originCol != len(arr[0]) - 1:
				tileDestination = arr[originRow][originCol + 1]
				tileDestination.connections[3] = true
				tileOrigin.rightTile = tileDestination
				tileDestination.leftTile = tileOrigin
			
			newLink.set_position(Vector2(originPos[0] + 127, originPos[1] + 52)) 
			newLink.get_node("HorizontalLink").show()
		"down":
			tileOrigin.connections[2] = true
			
			if originRow != len(arr) - 1:
				tileDestination = arr[originRow + 1][originCol]
				tileDestination.connections[0] = true
				tileOrigin.belowTile = tileDestination
				tileDestination.aboveTile = tileOrigin
			
			newLink.set_position(Vector2(originPos[0] + 52, originPos[1] + 127)) 
			newLink.get_node("VerticalLink").show()

		"left":
			tileOrigin.connections[3] = true
			
			if originCol != 0:
				tileDestination = arr[originRow ][originCol - 1]
				tileDestination.connections[1] = true
				tileOrigin.leftTile = tileDestination
				tileDestination.rightTile = tileOrigin

			newLink.set_position(Vector2(originPos[0] -173, originPos[1] + 52)) 
			newLink.get_node("HorizontalLink").show()
		_:
			print("GenerateTileLinks.gd: Unmatched match statement in makeLink function")

func generateConnections(row, col, movingRow, movingCol, curLayer):
	var maxLayer = row / 2
	
	while curLayer < maxLayer:
		for i in range(curLayer * 2):
			movingRow += 1
			determineLinksToBeMade(arr[movingRow][movingCol])
		for i in range(curLayer * 2):
			movingCol -= 1
			determineLinksToBeMade(arr[movingRow][movingCol])
		for i in range(curLayer * 2):
			movingRow -= 1
			determineLinksToBeMade(arr[movingRow][movingCol])
		for i in range(curLayer * 2):
			movingCol += 1
			determineLinksToBeMade(arr[movingRow][movingCol])
		
		# Move upright one to enter next layer
		movingRow -= 1
		movingCol += 1
		
		curLayer += 1

func determineLinksToBeMade(tile):
	randomize()
	var randNumberOfConnections = rand_range(0, 1)
	
	if randNumberOfConnections < ONE_CONN_CHANCE:
		makeRandomLinks(tile, 1)
	elif randNumberOfConnections < TWO_CONN_CHANCE:
		makeRandomLinks(tile, 2)
	elif randNumberOfConnections < THREE_CONN_CHANCE:
		makeRandomLinks(tile, 3)
	elif randNumberOfConnections < FOUR_CONN_CHANCE:
		makeRandomLinks(tile, 4)
	else:
		print("GenerateTileLinks, determineLinksToBeMade, invalid entry?")

func makeRandomLinks(tile, linksToBeMade):
	var numConnections = 0
	var randDirection = 0
	randomize()
	
	# Find how many connections currently exist
	for item in tile.connections:
		if item == true:
			numConnections += 1
	
	while numConnections < linksToBeMade:
		randDirection = rand_range(0, 1)
		
		if randDirection < upWeight:
			makeLink(tile, "up")
			upWeight -= 0.06
			rightWeight += 0.02
			downWeight += 0.02
			leftWeight += 0.02
		elif randDirection < rightWeight:
			makeLink(tile, "right")
			upWeight += 0.02
			rightWeight -= 0.06
			downWeight += 0.02
			leftWeight += 0.02
		elif randDirection < downWeight:
			makeLink(tile, "down")
			upWeight += 0.02
			rightWeight += 0.02
			downWeight -= 0.06
			leftWeight += 0.02
		elif randDirection < leftWeight:
			makeLink(tile, "left")
			upWeight += 0.02
			rightWeight += 0.02
			downWeight += 0.02
			leftWeight -= 0.06
		
		numConnections += 1
	
func fixIslands():
	var unTouched = []
	
	# Generates a copy array with only false values of the same size as the mainArray
	touched = createTouched()
	
	# Start at home position of array
	touchAllConnectedTiles(arr[len(arr) / 2][len(arr) / 2])
	
	# Get a array of all tiles that are untouched
	unTouched = checkCompletion()
	
	# Connect all unTouched tiles with random links until they meet a touched neighbour
	connectUntouchedTiles(unTouched)
	
func checkCompletion():
	# Untouched array keeps track of all tiles that are currently not able to be reached
	var unTouched = []
	
	var rowIndex = 0
	var colIndex = 0
	
	for row in touched:
		colIndex = 0
		for item in row:
			if item == false:
				unTouched.append(arr[rowIndex][colIndex])
			colIndex += 1
		rowIndex += 1
	
	return unTouched
	
func connectUntouchedTiles(unTouched):
	var removalCounter = 0
	var newLinksMade = null
	
	while !unTouched.empty():
		# Generates randomly determines links for 10% of the unTouched tiles so long as the link is going to
		# a tile that is touched already
		newLinksMade = makeNewLinks(unTouched)
		
		# Actually make the link and touch all newly connected tiles
		for direction in newLinksMade:
			match newLinksMade[direction]:
				"up":
					makeLink(direction, "up")
					touchAllConnectedTiles(direction)
				"right":
					makeLink(direction, "right")
					touchAllConnectedTiles(direction)
				"left":
					makeLink(direction, "left")
					touchAllConnectedTiles(direction)
				"down":
					makeLink(direction, "down")
					touchAllConnectedTiles(direction)
				_:
					print("GenerateTileLinks.gd: Unmatched direction, ")
		
		# Loops through unTouched and removes all touched tiles
		removalCounter = 0
		for tile in unTouched:
			if touched[tile.row][tile.col] == true:
				unTouched.remove(removalCounter)
			removalCounter += 1
	
func createTouched():
	# Creates an array that will keep track of all tiles that are accessible from center
	var touched = []
	var index = 0
	
	for row in arr:
		touched.append([])
		
		for item in row:
			touched[index].append(false)
			
		index += 1
		
	return touched
	
func searchForTouched(tile):
	# Searches all neighbouring tiles and returns the first that is accessible from center
	if tile.row != 0 and touched[tile.row - 1][tile.col] == true:
		return "up"
	if tile.row != len(arr) - 1 and touched[tile.row + 1][tile.col] == true:
		return "down"
	if tile.col != 0 and touched[tile.row][tile.col - 1] == true:
		return "left"
	if tile.col != len(arr[0]) - 1 and touched[tile.row][tile.col + 1] == true:
		return "right"
	else:
		return "none"
	
func touchAllConnectedTiles(tile):
	var curTile = null
	var coords = null
	var queue = []
	queue.append([tile.row, tile.col])

	while !queue.empty():
		# Get next tile in queue
		coords = queue.pop_front()
		
		curTile = arr[coords[0]][coords[1]]
		
		# Mark touched
		touched[coords[0]][coords[1]] = true
		
		# For up
		if curTile.row != 0:
			if curTile.connections[0] == true:
				if touched[curTile.row - 1][curTile.col] == false:
					touched[curTile.row - 1][curTile.col] = true
					queue.append([curTile.row - 1, curTile.col])
					
		# For right
		if curTile.col != len(arr[0]) - 1:
			if curTile.connections[1] == true:
				if touched[curTile.row][curTile.col + 1] == false:
					touched[curTile.row][curTile.col + 1] = true
					queue.append([curTile.row, curTile.col + 1])
		# For down
		if curTile.row != len(arr) - 1:
			if curTile.connections[2] == true:
				if touched[curTile.row + 1][curTile.col] == false:
					touched[curTile.row + 1][curTile.col] = true
					queue.append([curTile.row + 1, curTile.col])
		# For left
		if curTile.col != 0:
			if curTile.connections[3] == true:
				if touched[curTile.row][curTile.col - 1] == false:
					touched[curTile.row][curTile.col - 1] = true
					queue.append([curTile.row, curTile.col - 1])

func makeNewLinks(unTouched):
	# Makes new links in 10% of the unTouched tiles towards neighbours that are accessible from the center
	var length = len(unTouched)
	var newLinksToBeMade = 0
	var directions = {}
	var tempDirection
	var rand
	
	if length < 100:
		newLinksToBeMade = length
	else:
		newLinksToBeMade = length / 10
	
	for i in range(newLinksToBeMade):
		rand = randi() % length
		tempDirection = searchForTouched(unTouched[rand])
		if tempDirection != "none":
			directions[unTouched[rand]] = tempDirection
		
	return directions
	
	
	
