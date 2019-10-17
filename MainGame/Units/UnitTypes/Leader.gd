extends Node

var currentHP = 0
var maxHP
var offense
var defense
var speed

var baseMaxHP = 100
var baseOffense = 20
var baseDefense = 20
var baseSpeed = 10

var numUnits = 0
var efficacy = 0

func _ready():
	pass

func addFreshUnit(num):
	numUnits += num
	updateFreshStats()
	calcEfficacy()
	
func updateFreshStats():
	currentHP += numUnits * baseMaxHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	defense = numUnits * baseDefense
	speed = numUnits * baseSpeed
	

func mergeUnit(newUnit):
	numUnits += newUnit.numUnits
	updateCurrentStats(newUnit)
	calcEfficacy()
	
func updateCurrentStats(newUnit):
	currentHP = currentHP + newUnit.currentHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	defense = numUnits * baseDefense
	speed = numUnits * baseSpeed

func calcEfficacy():
	efficacy = float(currentHP / maxHP)
	if efficacy < 0.1:
		efficacy = 0.1
	if efficacy > 0.85:
		efficacy = 1.00



