extends Control

var leader = null
var selectedUnits = []
var overUnit = false
var currentUnit = null
var globalSelected = ""


func _ready():
	pass # Replace with function body.

func _input(event):
	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
	if event is InputEventMouseButton and !event.is_pressed():
		if overUnit and Input.is_key_pressed(KEY_SHIFT) and (globalSelected == "e" or globalSelected == "unit"):
			# Hides con
			print("Here")
			get_node("../../UI/BottomUI/MiddleSection/TileInfo").emptyTileGroup()
			if !(currentUnit in selectedUnits):
				unitClicked(currentUnit)
		elif overUnit and !Input.is_key_pressed(KEY_SHIFT):
			if selectedUnits.empty():
				unitClicked(currentUnit)
			else:
				_unhighlightAll()
				unitClicked(currentUnit)

		# Click onto something that was not a unit
		if !overUnit and !selectedUnits.empty() and !Input.is_key_pressed(KEY_SHIFT) and event.button_index == 1:
			_unhighlightAll()

func makeLeaderUnit(baseTile):
	var baseTilePosition = baseTile.get_position()
	var unit = preload("Units/Unit.tscn")
	leader = unit.instance()
	leader.add_to_group("Units")
	leader.setTile(baseTile)
	baseTile.setUnitStationed(leader)
	leader.createUnit("Leader", 1)
	leader.set_position(Vector2(baseTilePosition[0], baseTilePosition[1] - 75))
	add_child(leader)
	
func setGlobalSelected():
	get_tree().get_root().get_node("Control").selectSomething("unit")
	
func unitClicked(unit):
#	if Input.mo
#	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
#	if globalSelected == "e" or globalSelected == "unit":
	setGlobalSelected()
	unit.get_node("Highlight").show()
	if !checkIfUnitAlreadySelected(unit):
		selectedUnits.append(unit)
		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").displayUnitGroup(unit)
	
func _unhighlightAll():
	get_tree().get_root().get_node("Control").unselectEverything()
	if !selectedUnits.empty():
		for unit in selectedUnits:
			unit.get_node("Highlight").hide()
		selectedUnits = []
		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitInformation").unselectAll()

func _mouseExited():
	currentUnit = null
	overUnit = false

func _mouseEntered(unit):
	currentUnit = unit
	overUnit = true
	
func checkIfUnitAlreadySelected(unit):
	for item in selectedUnits:
		if item == unit:
			return true
	return false
		
func _on_AreaSelected(positions):
	var startX = min(positions[0].x, positions[1].x)
	var startY = min(positions[0].y, positions[1].y)
	var endX = max(positions[0].x, positions[1].x)
	var endY = max(positions[0].y, positions[1].y)
	
	var units = get_tree().get_nodes_in_group("Units")
	var unitsInArea = []
	
	for unit in units:
		if checkEachCorner(unit, startX, startY, endX, endY):
			unitsInArea.append(unit)
#		print(unit.get_position())
	
	# If shift isnt held, unhighlight all before selecting units.
	if !Input.is_key_pressed(KEY_SHIFT):
		if !(selectedUnits.empty()):
			_unhighlightAll()
	
	# Select all units in box
	for unit in unitsInArea:
		if !(unit in selectedUnits):
			unitClicked(unit)
func checkEachCorner(unit, startX, startY, endX, endY):
	var topLeft = unit.get_position()
	var topRight = topLeft
	topRight.x = topRight.x + 75
	var botLeft = topLeft
	botLeft.y = botLeft.y + 75
	var botRight = topLeft
	botRight.x = botRight.x + 75
	botRight.y = botRight.y + 75
	
	var corners = [topLeft, topRight, botLeft, botRight]
	var inArea = false
	
	for corner in corners:
		inArea = checkIfCornerInArea(corner, startX, startY, endX, endY)
		if inArea == true:
			return true
	
func checkIfCornerInArea(corner, startX, startY, endX, endY):
	if corner.x > startX and corner.x < endX:
		if corner.y > startY and corner.y < endY:
			return true
	return false
	