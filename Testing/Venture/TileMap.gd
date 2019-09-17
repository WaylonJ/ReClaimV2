extends TileMap

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

var randDirection = ""
var newDirection = false
var newConnection = ""

#Used with creating the dictionary that holds all the nodes.
var nodeDict = {}
var numberOfNodes = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	initialMapFill()				#This should be done in map creation or expansion
	makeConnections()				#This should be done in map creation or expansion
	accessibilityAndStepsCrawler()	#This should be done in map creation or expansion
	ensureAllAccessible()			#This should be done in map creation or expansion
	reDrawTiles()					#This should be done in map creation or expansion
	
	for i in nodeDict:
		print(nodeDict[i])


#Creates the initial map.
func initialMapFill():
	#int availableTypesOfTiles = _getAvailableTiles()
	#This will need to be made, for now using the most basic of tiles
	
	#coordinates
	var newestCellX = 2
	var newestCellY = 2
	
	#Holds the current tier and number of tiers built from the center
	var currentTier = 0
	var maxTier = 5
	
	mapFill(currentTier, maxTier, newestCellX, newestCellY) #will need to add availableTypesOfTiles here

#Initializes home tiles and fills rest of spots with enemy tiles.
func mapFill(currentTier, maxTier, newestCellX, newestCellY):
	#Initializes first 2 cells, origin and first enemy
	var incrementStart = 0
	var incrementMiddle = 0
	var incrementEnd = 0
	
	#Initialized first 2 tiers
	if currentTier == 0:
		set_cell(newestCellX, newestCellY, 0)
		addToDict(numberOfNodes, Vector2(newestCellX, newestCellY), [], "Home", 0)
		nodeDict["index0"].accessible = true
		nodeDict["index0"].cleared = true
		nodeDict["index0"].locked = false
		newestCellY -= 1
		
		#initialize incremental amount for Tier 2
		incrementStart = 2
		incrementMiddle = 2
		
		#increment (right) until next corner
		for i in range(incrementStart):
			makeCell(newestCellX, newestCellY)
			newestCellX += 1
		#This fixes the index going 1 past it needs to for the initial setup.
		newestCellX -= 1
		
		#increment (down) until next corner
		for i in range(incrementMiddle):
			newestCellY += 1
			makeCell(newestCellX, newestCellY)
		
		#increment (left) until next corner
		for i in range(incrementMiddle):
			newestCellX -= 1
			makeCell(newestCellX, newestCellY)
		
		#increment (up) until next corner
		for i in range(incrementMiddle):
			newestCellY -= 1
			makeCell(newestCellX, newestCellY)
			
		#Bring the latest cell into the next tier, one to the left of the beginning
		newestCellY -= 1 
		
		currentTier = 2
		nodeDict["index1"].locked = false
	
	#initializes the rest of the cells dependent on current tier and max tier
	while currentTier < maxTier:
		#initialize incremental amount for current Tier
		incrementStart = currentTier + 1
		incrementMiddle = (currentTier * 2) 
		incrementEnd = currentTier - 1

		#increment (right) until next corner
		for i in range(incrementStart):
			newestCellX += 1
			makeCell(newestCellX, newestCellY)

		#increment (down) until next corner
		for i in range(incrementMiddle):
			newestCellY += 1
			makeCell(newestCellX, newestCellY)

		#increment (left) until next corner
		for i in range(incrementMiddle):
			newestCellX -= 1
			makeCell(newestCellX, newestCellY)

		#increment (up) until next corner
		for i in range(incrementMiddle):
			newestCellY -= 1
			makeCell(newestCellX, newestCellY)
			
		#increment (right) until the tier is filled
		for i in range(incrementEnd):
			newestCellX += 1
			makeCell(newestCellX, newestCellY)

		#Bring the latest cell into the next tier, one to the left of the beginning
		newestCellY -= 1 

		currentTier += 1
	
	

#Creates a new entry for the nodeDict and adds to the incrementer keeping track of total nodes.
func addToDict(index, vector, connections, type, steps):
	var newKey = "index" + str(index)
	nodeDict[newKey] = {
		"index": index,				#index used to reference based on the clockwise drawing pattern
		"vector": vector,			#2dVector (x, y)
		"connections": connections, #array of the connections, e.g. ["up", "right"]
		"connectionVectors": [],	#NOT USED - array of connections, e.g. [(3,2), (4,3)] 
		"connMade": false, 			#NOT USED - Indicates if Conns were made here or not
		"type": type,				#Type of tile, e.g. Home, Enemy, Factory
		"accessible": false, 		#Indicates whether a path can be made from home to this tile
		"cleared": false,			#Indicates whether the tile has been cleared
		"locked": true,				#Indicates lock status, whether the player can access it currently or not
		"stepsFromCenter": steps	#Indicates the minimum number of steps to reach this tile from home
	}
	numberOfNodes += 1

#Creates the new cell and adds it to dict
func makeCell(newestCellX, newestCellY):
	set_cell(newestCellX, newestCellY, 16) 
	addToDict(numberOfNodes, Vector2(newestCellX, newestCellY), [], "Enemy", -1)

#Adds connections to each of the tiles based on probability of past connections
func makeConnections():
	var randConns = -1
	
	for i in nodeDict:
		#initialzes rand variable that determines number of Connections
		randConns = rand_range(0, 1)
		if(nodeDict[i].get("index") == 0):
			pass
		else:
			if(randConns < ONE_CONN_CHANCE):
				makeConnectionHere(nodeDict[i], 1)
			elif(randConns < TWO_CONN_CHANCE):
				makeConnectionHere(nodeDict[i], 2)
			elif(randConns < THREE_CONN_CHANCE):
				makeConnectionHere(nodeDict[i], 3)
			elif(randConns < FOUR_CONN_CHANCE):
				makeConnectionHere(nodeDict[i], 4)
	
	removeHomeConnections()

#Helper function that points towards manageConns
func makeConnectionHere(dictPart, numOfConns):
	var currentConnections = dictPart.get("connections")
	if numOfConns == 1:
		manageConns(dictPart, numOfConns, currentConnections)
	
	if numOfConns == 2:
		manageConns(dictPart, numOfConns, currentConnections)

	if numOfConns == 3:
		manageConns(dictPart, numOfConns, currentConnections)
				
	if numOfConns == 4:
		manageConns(dictPart, numOfConns, currentConnections)

#Updates the tile that we found a new connection for
func manageConns(dictPart, numOfConns, currentConnections):
	#Checks to see if this node has any connections yet or not. If so, end sequence
	if currentConnections.size() > numOfConns - 1:
		return
	else:
		#Runs for the number of times needed to get up to 2 connections made.
		for i in range(numOfConns - currentConnections.size()):
			newConnection = updateWeightsAndGetConnection(currentConnections)
			currentConnections.append(newConnection)
			dictPart.connections = currentConnections
			updateOtherTileConnectedTo(dictPart, newConnection)

#Updates the tile that was just connected to
func updateOtherTileConnectedTo(dictPart, newConnection):
#	print(dictPart)
	var vectorOfCurrent = dictPart.get("vector")
	var vectorOfTarget = vectorOfCurrent
	var oppositeConnection = ""
	
	#Gets information from the connected tile
	var result = getConnectedTileVectorAndDirection(newConnection, vectorOfCurrent)
	oppositeConnection = result[0]
	vectorOfTarget = result [1]
	
	for i in nodeDict:
		if nodeDict[i].get("vector") == vectorOfTarget:
			nodeDict[i].connections.append(oppositeConnection)

#Updates accessibility for the current tile and the tile connected to if applicable
func accessibilityAndStepsCrawler():
	var upNextList = ["index0"]
	var doneList = []
	var steps = 0
	var currentTile
	var connectedTile
	
	while upNextList.empty() == false:
		#Get Next tile, add currentTile to finished list and update current steps from center
		currentTile = nodeDict[upNextList.pop_back()]
		doneList.append("index" + str(currentTile.get("index")))
		steps = currentTile.stepsFromCenter + 1
		
		#For each connected tile, update steps, accessible, and add to upNextList
		for item in currentTile.get("connections"):
			connectedTile = getConnectedTile(currentTile, item)
			#Ensures we aren't entering areas that haven't been generated yet
			if connectedTile != null:
				#Ensures no repeats
				if !doneList.has("index" + str(connectedTile.get("index"))):
					upNextList.push_front("index" + str(connectedTile.get("index")))
					connectedTile.stepsFromCenter = steps
					connectedTile.accessible = true

#Returns a tile's connected partner 
func getConnectedTile(currentTile, direction):
	var result = getConnectedTileVectorAndDirection(direction, currentTile.vector)
	var vectorOfNew = result[1]
	
	for i in nodeDict:
		if nodeDict[i].vector == vectorOfNew:
			return nodeDict[i]
	pass

#Gets connected tile Vector and direction leading back to original tile
func getConnectedTileVectorAndDirection(direction, vector):
	var returnVector = vector
	var returnDirection
	if direction == "up":
		returnVector += Vector2(0, -1)
		returnDirection = "down"
	elif direction == "right":
		returnVector += Vector2(1, 0)
		returnDirection = "left"
	elif direction == "down":
		returnVector += Vector2(0, 1)
		returnDirection = "up"
	elif direction == "left":
		returnVector += Vector2(-1, 0)
		returnDirection = "right"
	
	return [returnDirection, returnVector]

#Updates the weight of future connections based on the most recent connections. 
func updateWeightsAndGetConnection(currentConnections):
	var randWeights
	while newDirection == false:
		randWeights = rand_range(0, 1)
		
		#Determines random direction based on weight, either up / right / down / left
		randDirection = findRandDirection(randWeights)
		
		#Determines if the random direction chosen is a new random direction for the tile
		newDirection = determineIfNewDirection(randDirection, currentConnections)
	newDirection = false
	
	#Alters the weights
	if randDirection == "up":
		upWeight -= 0.06
		rightWeight += 0.02
		downWeight += 0.02
		leftWeight += 0.02
		return "up"
	elif randDirection == "right":
		rightWeight -= 0.06
		upWeight += 0.02
		downWeight += 0.02
		leftWeight += 0.02
		return "right"
	elif randDirection == "down":
		downWeight -= 0.06
		upWeight += 0.02
		rightWeight += 0.02
		leftWeight += 0.02
		return "down"
	elif randDirection == "left":
		leftWeight -= 0.06
		upWeight += 0.02
		rightWeight += 0.02
		downWeight += 0.02
		return "left"
		
	return randDirection

#Finds which random direction to choose
func findRandDirection(randWeights):
#	print("randWeights: " + str(randWeights))
	if randWeights < upWeight:
		randDirection = "up"
	elif randWeights < rightWeight:
		randDirection = "right"
	elif randWeights < downWeight:
		randDirection = "down"
	elif randWeights < leftWeight:
		randDirection = "left"
	return randDirection

#Determines if the random direction is a new direction for the current tile.
func determineIfNewDirection(randDirection, currentConnections):
	for item in currentConnections:
		if item == randDirection:
			return false
	return true	

#Remove right, down, and left connections from home
func removeHomeConnections():
	removeConnection(nodeDict["index0"], "right")
	removeConnection(nodeDict["index0"], "down")
	removeConnection(nodeDict["index0"], "left")

#Removes connection given the tile and the direction to remove
func removeConnection(theTile, direction):
	var vector = theTile.vector
	if(direction == "right"):
		theTile.connections.erase("right")
		vector += Vector2(1, 0)
		for i in nodeDict:
			if nodeDict[i].get("vector") == vector:
				nodeDict[i].connections.erase("left")
	
	if(direction == "down"):
		theTile.connections.erase("down")
		vector += Vector2(0, 1)
		for i in nodeDict:
			if nodeDict[i].get("vector") == vector:
				nodeDict[i].connections.erase("up")
	
	if(direction == "left"):
		theTile.connections.erase("left")
		vector += Vector2(-1, 0)
		for i in nodeDict:
			if nodeDict[i].get("vector") == vector:
				nodeDict[i].connections.erase("right")
	
	if(direction == "up"):
		theTile.connections.erase("up")
		vector += Vector2(0, -1)
		for i in nodeDict:
			if nodeDict[i].get("vector") == vector:
				nodeDict[i].connections.erase("down")

#Checks to find any tiles that aren't accessible, adds a connection and rechecks accessibility
func ensureAllAccessible():
	var newConnection
	var allAccessible = false
	while allAccessible == false:
		allAccessible = true
		#If the for loops can't find an inaccessible tile, then this function is complete
		for tile in nodeDict:
			if nodeDict[tile].get("accessible") == false:
				newConnection = updateWeightsAndGetConnection(nodeDict[tile].connections)
				nodeDict[tile].connections.append(newConnection)
				updateOtherTileConnectedTo(nodeDict[tile], newConnection)
				allAccessible = false
		#If an inaccessible tile is found, then rerun the crawler and recheck to see if all are accessible
		if allAccessible == false:
			accessibilityAndStepsCrawler()


#Redraws the tiles
func reDrawTiles():
	var imageIndex
	for i in nodeDict:
		if i == "index0":
			continue
		else:
			imageIndex = getImageIndex(nodeDict[i].get("connections"))
			set_cell(nodeDict[i].get("vector").x, nodeDict[i].get("vector").y, imageIndex)

#Maps the tiles to their appropriate location on the TileMap
func getImageIndex(connections):
	var up = false
	var right = false
	var down = false
	var left = false
	
	for item in connections:
		if item == "up":
			up = true
		elif item == "right":
			right = true
		elif item == "down":
			down = true
		elif item == "left":
			left = true
	if !up && !right && !left && !down:
		return 16
	if up && right && left && down:
		return 15
	if up && right && left && !down:
		return 14
	if up && !right && left && down:
		return 13
	if !up && right && left && down:
		return 12
	if up && right && !left && down:
		return 11
	if !up && right && left && !down:
		return 10
	if up && !right && !left && down:
		return 9
	if up && !right && left && !down:
		return 8
	if !up && !right && left && down:
		return 7
	if !up && right && !left && down:
		return 6
	if up && right && !left && !down:
		return 5
	if !up && !right && left && !down:
		return 4
	if !up && !right && !left && down:
		return 3
	if !up && right && !left && !down:
		return 2
	if up && !right && !left && !down:
		return 1

