extends "res://MainGame/Units/UnitTypes/UnitBase.gd"

func _init():
	currentHP = 0

	baseMaxHP = 20
	baseOffense = 5
	baseSpeed = 10
	baseAttackSpeed = 1.5
	basePRes = 0.1
	
	numUnits = 0
	efficacy = 0
