extends Node

var currentHP
var maxHP
var offense
var defense
var speed
var pRes

var baseMaxHP
var baseOffense
var baseSpeed
var baseAttackSpeed
var basePRes

var numUnits
var efficacy
var isAlly = true
var isAlive = true

func updateFreshStats():
	currentHP += numUnits * baseMaxHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	speed = numUnits * baseSpeed
	pRes = basePRes
	
func addFreshUnit(num):
	numUnits += num
	updateFreshStats()
	calcEfficacy()

func mergeUnit(newUnit):
	numUnits += newUnit.numUnits
	updateCurrentStats(newUnit)
	calcEfficacy()

func updateCurrentStats(newUnit):
	currentHP = currentHP + newUnit.currentHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	speed = numUnits * baseSpeed

func calcEfficacy():
	efficacy = float(currentHP / maxHP)
	if efficacy < 0.1:
		efficacy = 0.1
	if efficacy > 0.85:
		efficacy = 1.00

func getAutoAttack():
	var amount = offense
	return amount

func takeDamage(amount):
	amount *= (1 - basePRes)
	currentHP -= amount
#	print("Taking damage: " + str(amount))
	if currentHP <= 0:
		killUnit()

func killUnit():
	isAlive = false

