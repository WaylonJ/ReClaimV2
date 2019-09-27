extends Control

var bigArray = []


func _ready():
	var Tile = preload("Tiles/Tile.tscn")	

	var baseArr = makeBaseArray(Tile)
	
	print("Finished creating TileSet")
	
	get_node("UI/HiddenItems/HoveringBldgImage").call("_get_all_tiles")
	
#	baseArr[0][0].rect_position = Vector2(1111, 1111)



func makeBaseArray(Tile):
	var arr = []

	for row in range(15):
		arr.append([])
		for col in range(15):
			var myObj = Tile.instance()
			myObj.add_to_group("Tiles")
			myObj.rect_position = Vector2((-7 + row) * 175, (-7 + col) * 175)
			arr[row].append(myObj)
	
	for row in arr:
		for item in row:
			add_child(item)
	return arr
	
#func _input(event):
	# Hides the golden highlight border after a click
#	if event is InputEventMouseButton:
#		get_node("UI/HiddenItems/SelectedHighlight").hide()