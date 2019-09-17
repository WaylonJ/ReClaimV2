extends Control

var bigArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var Tile = preload("Tiles/Tile.tscn")	

	var baseArr = makeBaseArray(Tile)
	
	print("Finished creating TileSet")
	
#	baseArr[0][0].rect_position = Vector2(1111, 1111)



func makeBaseArray(Tile):
	var arr = []

	for row in range(15):
		arr.append([])
		for col in range(15):
			var myObj = Tile.instance()
			myObj.rect_position = Vector2((-7 + row) * 175, (-7 + col) * 175)
			arr[row].append(myObj)
	
	for row in arr:
		for item in row:
			add_child(item)
	return arr