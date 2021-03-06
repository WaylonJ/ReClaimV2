extends Button

var goblinPng = preload("res://MainGame/Units/Resources/TileIcons/PH_Unit_Goblin.png")
var leaderPng = preload("res://MainGame/Units/Resources/TileIcons/PH_Unit_Leader.png")

var portrait
var unitType = "A"

var numUnits = 0

func copyUnit(unit, unitGroup):
	match unit:
		"Leader":
			numUnits += unitGroup.numLeader 
			portrait = leaderPng
			unitType = "Leader"
			
		"Goblin":
			numUnits += unitGroup.numGoblin
			portrait = goblinPng
			unitType = "Goblin"
		_:
			print("UI UNIT: copy unit fail?")
			
	get_node("BG").set("texture", portrait)
	updateInfo()

func updateInfo():
	get_node("NumUnits").set_text(str(numUnits))
	
func mergeUnit(otherUnit):
	numUnits += otherUnit.get_node("HBoxContainer/UI_Unit").numUnits
	otherUnit.queue_free()
	updateInfo()
