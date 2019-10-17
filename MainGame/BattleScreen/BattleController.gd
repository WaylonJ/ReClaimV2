extends Node

var allyUnits
var enemyUnits
var allUnits

var tiles

var attackRates = {}
var targets = {}

func _ready():
	set_process(false)
	pass # Replace with function body.

func addBattle(ally, enemy, tileGroup):
	print("Adding Battle")
	allyUnits = ally
	enemyUnits = enemy
	allUnits = [ally, enemy]
	tiles = tileGroup
	
	initializeAttackRates()
	initializeAutoAttackTargets()
	
	set_process(true)
	
func _process(delta):

	for unit in attackRates:
		attackRates[unit] -= delta
		if attackRates[unit] < 0:
			triggerAttack(unit)
			resetAttackRates(unit)

func initializeAttackRates():
	for item in allyUnits.formation:
		resetAttackRates(item)
	for item in enemyUnits.formation:
		resetAttackRates(item)
		
func initializeAutoAttackTargets():
	for group in allUnits:
		for unit in group.formation:
			match unit:
				"Leader":
					targets[unit] = attemptToAutoTarget(true, true)
				"Goblin":
					targets[unit] = attemptToAutoTarget(true, true)
				"baseEnemy":
					targets[unit] = attemptToAutoTarget(true, false)
				_:
					print("BattleController.gd: Mismatch")
			
func resetAttackRates(item):
	match item:
		"Leader":
			attackRates[item] = 3.0
		"Goblin":
			attackRates[item] = 1.5
		"baseEnemy":
			attackRates[item] = 3.5
		_:
			print("BattleController.gd: Mismatch")
			
func triggerAttack(unit):
	var target = targets[unit]
#	targettedUnit = getTargettedUnit(target)
	
	return
	
	
	match unit:
		"Leader":
			print("Leader attacked")
		"Goblin":
			print("Goblin attacked")
		"baseEnemy":
			print("baseEnemy attacked")
		_:
			print("BattleController.gd: Mismatch")
	
func attemptToAutoTarget(melee, ally):
	
#	var formation =
	var order
	var row
	var col
	
	if ally:
		for index in range(6):
			for item in enemyUnits.formation:
				if enemyUnits.formation[item] == index:
					return index
	else:
		for index in range(6):
			for item in allyUnits.formation:
				if allyUnits.formation[item] == index:
					return index


