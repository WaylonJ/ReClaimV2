extends Control

var leader = null
var selectedUnits = []
var overUnit = false
var globalSelected = ""

func _ready():
	pass # Replace with function body.

func makeLeaderUnit(baseTile):
	var baseTilePosition = baseTile.get_position()
	var unit = preload("Units/Unit.tscn")
	leader = unit.instance()
	leader.add_to_group("Units")
	leader.setTile(baseTile)
	leader.createUnit("Leader", 1)
	leader.set_position(Vector2(baseTilePosition[0], baseTilePosition[1] - 75))
	add_child(leader)
	
func setGlobalSelected():
	get_tree().get_root().get_node("Control").selectSomething("unit")
	
func _unitClicked(unit):
	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
	if globalSelected == "e" or globalSelected == "unit":
		setGlobalSelected()
		unit.get_node("Highlight").show()
		appendUnitIfNotAlreadyHere(unit)
#		selectedUnits.append(unit)
		print(selectedUnits)
		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitHolder").displayUnitGroup(unit)
	
func _unhighlightAll():
	get_tree().get_root().get_node("Control").unselectEverything()
	if !selectedUnits.empty():
		for unit in selectedUnits:
			unit.get_node("Highlight").hide()
		selectedUnits = []
		get_tree().get_root().get_node("Control/UI/BottomUI/MiddleSection/UnitHolder").unselectAll()

func _mouseExited():
	overUnit = false

func _mouseEntered():
	overUnit = true
	
func _input(event):
	if event is InputEventMouseButton and !event.is_pressed():
		# Click onto something that was not a unit
		if !overUnit and !selectedUnits.empty() and !Input.is_key_pressed(KEY_SHIFT):
			_unhighlightAll()

func appendUnitIfNotAlreadyHere(unit):
	for item in selectedUnits:
		if item == unit:
			return
	selectedUnits.append(unit)