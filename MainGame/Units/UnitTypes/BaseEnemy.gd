extends "res://MainGame/Units/UnitTypes/UnitBase.gd"

func _init():
	currentHP = 0
	
	baseMaxHP = 30
	baseOffense = 10
	baseSpeed = 5
	baseAttackSpeed = 3.5
	basePRes = 0.1
	
	numUnits = 0
	efficacy = 0
	isAlly = false
