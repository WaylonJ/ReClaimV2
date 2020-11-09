extends HBoxContainer

var tiles = []

func _ready():
	attachAllTilesToArray()
#	print(tiles)
	

func attachAllTilesToArray():
	var tempHolder
	for item in get_children():
		tempHolder = []
		for child in item.get_children():
			tempHolder.append(child)
		tiles.append(tempHolder)


# 0,0 | 1,0 | 2,0 | 3,0
# 0,1 | 1,1 | 2,1 | 3,1
# 0,2 | 1,2 | 2,2 | 3,2
func reset():
	for column in tiles:
		for tile in column:
			tile.get_node("unitImage").hide()
			tile.get_node("Health").hide()
			tile.get_node("Health").max_value = 0
			tile.get_node("Health").value = 0
			tile.get_node("Timer").hide()

func setUnitToPosition(unitRef, image, position):
	var unitImage
	var tile
	match position:
		0:
			tile = tiles[1][0]
		1:
			tile = tiles[1][1]
		2:
			tile = tiles[1][2]
		3:
			tile = tiles[0][0]
		4:
			tile = tiles[0][1]
		5:
			tile = tiles[0][2]
	unitImage = tile.get_node("unitImage")
	unitImage.set("texture", image)
	unitImage.show()
	
	setHealthBar(unitRef, tile)
	setAATimer(unitRef, tile)
	
func setHealthBar(unit, tile):
	var bar = tile.get_node("Health")
	bar.show()
	bar.max_value = unit.maxHP
	bar.value = unit.currentHP
	
func setAATimer(unit, tile):
	var timer = tile.get_node("Timer")
	timer.show()
	timer.max_value = 100.5
	timer.value = 0.0
	

func setEnemyToPosition(unit, image, position):
	var tile
	var unitImage
	var progressBar
	match position:
		0:
			tile = tiles[2][0]
		1:
			tile = tiles[2][1]
		2:
			tile = tiles[2][2]
		3:
			tile = tiles[3][0]
		4:
			tile = tiles[3][1]
		5:
			tile = tiles[3][2]
	
	unitImage = tile.get_node("unitImage")
	unitImage.set("texture", image)
	unitImage.show()
	
	setHealthBar(unit, tile)
	setAATimer(unit, tile)



