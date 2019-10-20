extends VBoxContainer

var tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	attachAllTilesToArray()
	

func attachAllTilesToArray():
	var tempHolder
	for item in get_children():
		tempHolder = []
		for child in item.get_children():
			tempHolder.append(child)
		tiles.append(tempHolder)

func setUnitToPosition(unitRef, image, position):
	var unitImage
	var tile
	match position:
		0:
			tile = tiles[0][1]
		1:
			tile = tiles[1][1]
		2:
			tile = tiles[2][1]
		3:
			tile = tiles[0][0]
		4:
			tile = tiles[1][0]
		5:
			tile = tiles[2][0]
	unitImage = tile.get_node("unitImage")
	unitImage.set("texture", image)
	unitImage.show()
	
	setHealthBar(unitRef, tile)
	
func setHealthBar(unit, tile):
	var bar = tile.get_node("Health")
	bar.show()
	bar.max_value = unit.maxHP
	bar.value = unit.currentHP

func setEnemyToPosition(unit, image, position):
	var tile
	var unitImage
	var progressBar
	match position:
		0:
			tile = tiles[0][2]
		1:
			tile = tiles[1][2]
		2:
			tile = tiles[2][2]
		3:
			tile = tiles[0][3]
		4:
			tile = tiles[1][3]
		5:
			tile = tiles[2][3]
	
	unitImage = tile.get_node("unitImage")
	unitImage.set("texture", image)
	unitImage.show()
	
	setHealthBar(unit, tile)



