extends Button

var goblinPng = preload("res://MainGame/Units/Resources/PH_Unit_Goblin.png")
var leaderPng = preload("res://MainGame/Units/Resources/PH_Unit_Goblin.png")

var portrait

var numUnits = 0

func copyUnit(unitType, unitGroup):
	match unitType:
		"Leader":
			numUnits += unitGroup.numLeader 
			portrait = leaderPng
			
		"Goblin":
			numUnits += unitGroup.numGoblin
			portrait = goblinPng
			
	