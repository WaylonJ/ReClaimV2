extends Control

var leader = null
var selectedUnits = []
var overUnit = false
var currentUnit = null
var globalSelected = ""

var inArea = false


func _ready():
	pass # Replace with function body.

func _input(event):
#	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
#	if event is InputEventMouseButton and !event.is_pressed() and event.position[1] < 540 and inArea:
#		inArea = false
#		if overUnit and Input.is_key_pressed(KEY_SHIFT) and (globalSelected == "e" or globalSelected == "unit"):
#			# Hides con
#			get_node("../../UI/BottomUI/MiddleSection/TileInfo").emptyTileGroup()
#			if !(currentUnit in selectedUnits):
#				unitClicked(currentUnit)
#		elif overUnit and !Input.is_key_pressed(KEY_SHIFT):
#			if selectedUnits.empty():
#				unitClicked(currentUnit)
#			else:
#				_unhighlightAll()
#				unitClicked(currentUnit)
#
#		# Click onto something that was not a unit
#		if !overUnit and !selectedUnits.empty() and !Input.is_key_pressed(KEY_SHIFT) and event.button_index == 1:
#			_unhighlightAll()
#	elif event is InputEventMouseButton and event.is_pressed() and event.position[1] < 540:
#		inArea = true
	pass
	
func makeTestEnemy(tile):
	var enemyTilePosition = tile.get_position()
	var unit = preload("Units/EnemyUnit.tscn")
	var enemy = unit.instance()
	enemy.add_to_group("Enemies")
	enemy.setTile(tile)
	tile.setEnemyStationed(enemy)
	enemy.createUnit("baseEnemy", 10)
	enemy.set_position(Vector2(enemyTilePosition[0] + 65, enemyTilePosition[1] - 75))
	add_child(enemy)
	
#func setGlobalSelected():
#	get_tree().get_root().get_node("Control").selectSomething("unit")
	
#func unitClicked(unit):
#	setGlobalSelected()
#	unit.get_node("Highlight").show()
#	if !checkIfUnitAlreadySelected(unit):
#		selectedUnits.append(unit)
#		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").displayUnitGroup(unit)
	
#func _unhighlightAll():
#	get_tree().get_root().get_node("Control").unselectEverything()
#	if !selectedUnits.empty():
#		for unit in selectedUnits:
#			# Ensures the unit wasn't queue'd for deletion
#			if is_instance_valid(unit):
#				unit.get_node("Highlight").hide()
#		selectedUnits = []
#		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").unselectAll()

func _mouseExited():
	currentUnit = null
	overUnit = false

func _mouseEntered(unit):
	currentUnit = unit
	overUnit = true
	
#func checkIfUnitAlreadySelected(unit):
#	for item in selectedUnits:
#		if item == unit:
#			return true
#	return false
		