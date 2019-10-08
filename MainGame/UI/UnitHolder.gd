extends HBoxContainer

var numUniqueUnits = 0
var unitGroupArray = []

func displayUnitGroup(unitGroup):
	HideOtherUIAndShowSelf()
	if self.is_visible():
		# Checks to see if this unit is already being displayed
		if unitGroup in unitGroupArray:
			return
	
	unitGroupArray.append(unitGroup)
	var uiUnit = preload("res://MainGame/UI/UI_Unit.tscn")
	
	numUniqueUnits = len(unitGroup.unitTypes)
	
	print(unitGroup)
	print(unitGroup)
	
	for typeOfUnit in unitGroup.unitTypes:
		var newUnit = uiUnit.instance()
		newUnit.get_node("HBoxContainer/UI_Unit").copyUnit(typeOfUnit, unitGroup)
#			match typeOfUnit:
#				"Leader":
#					newUnit.createUnit("Leader", unitGroup.numLeader)
#
#				"Goblin":
#					newUnit.createUnit("Goblin", unitGroup.numGoblin)
#
#				_:
#					print("UnitHolder.gd: Invalid typeOfUnit in match")
		get_node("RowHolder/TopRow").add_child(newUnit)
		print(newUnit)
		print(newUnit.get_position())
		newUnit.set_position(Vector2(get_parent().get_position()[0], get_parent().get_position()[1]))
	for item in get_node("RowHolder/TopRow").get_children():
		print(item)
		print(item.get_position())
			
func unselectAll():
	for child in get_node("RowHolder/TopRow").get_children():
		child.queue_free()
	numUniqueUnits = 0
	hide()
	get_parent().get_node("TileInfo").show()
	unitGroupArray = []
	
func HideOtherUIAndShowSelf():
	for child in get_parent().get_children():
		child.hide()
	show()