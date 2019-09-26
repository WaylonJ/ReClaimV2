extends TextureRect

var selectedTile = "aaa"
var Base_Tile = preload("res://MainGame/Tiles/Resources/PH_Tile_Base.png")

func _ready():
	pass

func _get_all_tiles():
	
	var tiles = get_tree().get_nodes_in_group("Tiles")
	
	for tile in tiles:
		print(tile)
		tile.connect("mouse_entered", self, "_on_mouse_entered_highlight", [tile])
		
	print(get_tree().get_nodes_in_group("Tiles"))

func _on_mouse_entered_highlight(tile):
	print(tile.get_children())
	tile.get_node("Background").set("texture", Base_Tile)
