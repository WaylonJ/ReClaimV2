extends HBoxContainer

var numUniqueUnits = 0
var unitGroupArray = []

var globalSelected

func displayUnitGroup(unitGroup):
#	print("here")
	HideOtherUIAndShowSelf()
	

	updateStatsOnUI(unitGroup)
	unitGroupArray.append(unitGroup)
	var uiUnit = preload("res://MainGame/UI/UI_Unit.tscn")

	numUniqueUnits = len(unitGroup.unitTypes)

	for typeOfUnit in unitGroup.unitTypes:
		var newUnit = uiUnit.instance()
		newUnit.get_node("HBoxContainer/UI_Unit").copyUnit(typeOfUnit, unitGroup)

		# Checks if this unit type is already here. If so, we're done. If not, add to row and set position
		if !checkIfUnitTypeAlreadyHere(newUnit):
			get_node("RowHolder/TopRow").add_child(newUnit)
			newUnit.set_position(Vector2(get_parent().get_position()[0], get_parent().get_position()[1]))

func unselectAll():
	for child in get_node("RowHolder/TopRow").get_children():
		child.free()
		
	# Reset variables
	numUniqueUnits = 0
	unitGroupArray = []
	get_node("AllStats").resetStats()
	
	# Change visibility of UI
	hide()
	get_parent().get_node("TileInfo").show()
	get_parent().get_node("NoSelection").show()
	

func HideOtherUIAndShowSelf():
	for child in get_parent().get_children():
		print(child.name)
		child.hide()
	show()

func checkIfUnitTypeAlreadyHere(newUnit):
	for item in get_node("RowHolder/TopRow").get_children():
		if newUnit.get_node("HBoxContainer/UI_Unit").unitType == item.get_node("HBoxContainer/UI_Unit").unitType:
			item.get_node("HBoxContainer/UI_Unit").mergeUnit(newUnit)
			return true
	return false

func checkIfUnitSelected(unit):
	for item in unitGroupArray:
		if item == unit:
			return true
	return false

func updateStatsOnUI(unitGroup):
	get_node("AllStats").updateStats(unitGroup)
