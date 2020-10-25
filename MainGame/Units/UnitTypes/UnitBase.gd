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

func updateFreshStats(num):
	numUnits += num
	currentHP += numUnits * baseMaxHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	speed = numUnits * baseSpeed
	pRes = basePRes
	
func addFreshUnit(num):
	updateFreshStats(num)
	calcEfficacy()
	aliveCheck()

func mergeUnit(newUnit):
	updateCurrentStats(newUnit)
	calcEfficacy()
	aliveCheck()

func updateCurrentStats(newUnit):
	numUnits += newUnit.numUnits
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
	var amount = offense * efficacy
	return amount

func takeDamage(amount):
	amount *= (1 - basePRes)
	currentHP -= amount
#	print("Ally: " + str(isAlly) + ", HP: " + str(currentHP))
#	print("Taking damage: " + str(amount))
	calcEfficacy()
	aliveCheck()

func aliveCheck():
	if currentHP > 0:
		isAlive = true
	else:
		isAlive = false

