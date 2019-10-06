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
var length = 0

func _ready():
	pass

func createLinks(array):
	arr = array
	length = len(array)

	# Makes the base tile always be connected to the 4 adjacent tiles
	setHomeConnections()

	# Make connections for the rest of the array.
	generateConnections(len(arr), len(arr[0]), len(arr) / 2 - 1, len(arr[0]) / 2 + 1, 1)
	
	# Ensure no nodes are left as 'islands' without a way to get to the homeNode
	fixIslands()
	
	
func setHomeConnections():
	var home = arr[length / 2][length / 2]
	
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
			
			# Sets the position of the Link and makes it appear
			newLink.set_position(Vector2(originPos[0] + 52, originPos[1] - 173)) 
			newLink.get_node("VerticalLink").show()
		"right":
			tileOrigin.connections[1] = true
			
			if originCol != len(arr[0]) - 1:
				tileDestination = arr[originRow][originCol + 1]
				tileDestination.connections[3] = true
			
			newLink.set_position(Vector2(originPos[0] + 127, originPos[1] + 52)) 
			newLink.get_node("HorizontalLink").show()
		"down":
			tileOrigin.connections[2] = true
			
			if originRow != len(arr) - 1:
				tileDestination = arr[originRow + 1][originCol]
				tileDestination.connections[0] = true
			
			newLink.set_position(Vector2(originPos[0] + 52, originPos[1] + 127)) 
			newLink.get_node("VerticalLink").show()

		"left":
			tileOrigin.connections[3] = true
			
			if originCol != 0:
				tileDestination = arr[originRow ][originCol - 1]
				tileDestination.connections[1] = true

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
	var touched = []
	var unTouched = []
	
	
	touched = createTouched()
	
	var row = len(arr) / 2
	var col = len(arr) / 2
	
	var queue = []
	var curTile = null
	var coords = null
	
	var done = false
	
	var test = 1
	
	while !done:
		# Start at home position of array
		queue.append([row, col])
		
		# Generates a copy array with only false values of the same size as the mainArray
		touched = createTouched()
		
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
						
#		var rowIn = 0
#		for row in touched:
#			for item in row:
#				if item == true:
#					printraw("T, ")
#				else:
#					printraw("F, ")
#			print("ROW NUMBER: " + str(rowIn))
#			rowIn += 1

		unTouched = checkCompletion(touched)
		
		if unTouched.empty():
			done = true
		else:
			appendLinkToBecomeTouched(unTouched)
		
	
func checkCompletion(touched):
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
	
func appendLinkToBecomeTouched(unTouched):
	var index = 0
	
	for tile in unTouched:
		index = 0
		for connection in tile.connections:
			if connection == false:
				match index:
					0:
						makeLink(tile, "up")
					1:
						makeLink(tile, "right")
					2:
						makeLink(tile, "down")
					3:
						makeLink(tile, "left")
#				tile.connections[index] = true
				break
			index += 1
	
func createTouched():
	var touched = []
	var index = 0
	
	for row in arr:
		touched.append([])
		
		for item in row:
			touched[index].append(false)
			
		index += 1
		
	return touched
	
	
	
	
	
	
	
	