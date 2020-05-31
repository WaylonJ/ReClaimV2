extends Node

var allyUnits
var enemyUnits
var allUnits


var tile

var allHPBars = []
var allAATimers = []

var hPBarRefsByUnitName = {}
var aATimerByUnitName = {}
var unitRefs = {}
var attackRates = {}
var baseAttackRates = {}
var currentTargettedPosition = {}
var allyPositions = {}
var enemyPositions = {}

func _ready():
	set_process(false)
	pass # Replace with function body.
	
func _process(delta):
	for unitName in attackRates:
		if !(unitRefs[unitName].isAlive):
			# Unit is dead, remove from attackRates
			attackRates.erase(unitName)
			checkBattleStatus()
			continue
		
		progressAAs(unitName, delta)
		if attackRates[unitName] < 0:
			triggerAttack(unitName)
			updateHealthBars()
			
			attackRates[unitName] = baseAttackRates[unitName]

func progressAAs(unitName, delta):
	attackRates[unitName] -= delta * 10
	aATimerByUnitName[unitName].value = 100 - ( attackRates[unitName] / baseAttackRates[unitName] ) * 100

func updateHealthBars():
	for group in allUnits:
		for unitName in group.unitTypes:
			hPBarRefsByUnitName[unitName].value = unitRefs[unitName].currentHP

func addBattle(ally, enemy, battleTile):
	allyUnits = ally
	enemyUnits = enemy
	allUnits = [ally, enemy]
	tile = battleTile
	
	initializeUnitRefs()
	initializeAttackRates()
	initializeAutoAttackTargets()
	initializePositions()
	initializeHealthBarRefsAndAARefs()
	
	set_process(true)

func initializeHealthBarRefsAndAARefs():
	# Get the references of all health bars in order
	for row in get_parent().get_node("Panel/HBoxContainer/BattleHolder").get_children():
		for panel in row.get_children():
			allHPBars.append(panel.get_node("Health"))
			
	for row in get_parent().get_node("Panel/HBoxContainer/BattleHolder").get_children():
		for panel in row.get_children():
			allAATimers.append(panel.get_node("Timer"))
			
	for item in allyPositions:
		match item:
			0:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[3]
				aATimerByUnitName[allyPositions[item]] = allAATimers[3]
			1:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[4]
				aATimerByUnitName[allyPositions[item]] = allAATimers[4]
			2:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[5]
				aATimerByUnitName[allyPositions[item]] = allAATimers[5]
			3:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[0]
				aATimerByUnitName[allyPositions[item]] = allAATimers[0]
			4:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[1]
				aATimerByUnitName[allyPositions[item]] = allAATimers[1]
			5:
				hPBarRefsByUnitName[allyPositions[item]] = allHPBars[2]
				aATimerByUnitName[allyPositions[item]] = allAATimers[2]

	for item in enemyPositions:
		match item:
			0:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[6]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[6]
			1:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[7]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[7]
			2:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[8]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[8]
			3:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[9]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[9]
			4:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[10]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[10]
			5:
				hPBarRefsByUnitName[enemyPositions[item]] = allHPBars[11]
				aATimerByUnitName[enemyPositions[item]] = allAATimers[11]

func initializeUnitRefs():
	for group in allUnits:
		for unitName in group.unitTypes:
			unitRefs[unitName] = group.unitRefs[unitName]

func initializePositions():
	for item in allyUnits.formation:
		allyPositions[allyUnits.formation[item]] = item
		
	for item in enemyUnits.formation:
		enemyPositions[enemyUnits.formation[item]] = item

func initializeAttackRates():
	for group in allUnits:
		for unitName in group.unitTypes:
			baseAttackRates[unitName] = unitRefs[unitName].baseAttackSpeed
			attackRates[unitName] = unitRefs[unitName].baseAttackSpeed
		
func initializeAutoAttackTargets():
	for group in allUnits:
		for unit in group.formation:
			match unit:
				"Leader":
					currentTargettedPosition[unit] = attemptToAutoTargetDefault(true, enemyUnits.formation)
				"Goblin":
					currentTargettedPosition[unit] = attemptToAutoTargetDefault(true, enemyUnits.formation)
				"baseEnemy":
					currentTargettedPosition[unit] = attemptToAutoTargetDefault(true, allyUnits.formation)
				_:
					print("BattleController.gd: Mismatch")
	
func triggerAttack(unitName):
	var targetPosition = currentTargettedPosition[unitName]
	var targettedUnit = getTargettedUnit(unitName, targetPosition)
	var attack = unitRefs[unitName].getAutoAttack()
	
	print(str(unitName) + " dealing this much damage: " + str(attack))
	targettedUnit.takeDamage(attack)

func getTargettedUnit(unitName, position):
	if unitRefs[unitName].isAlly:
		return unitRefs[enemyPositions[position]]
	else:
		return unitRefs[allyPositions[position]]

func attemptToAutoTargetDefault(melee, formation):
	if melee:
		for index in range(6):
			for item in formation:
				if formation[item] == index:
					return index
	else:
		for index in range(3, 6):
			for item in formation:
					if formation[item] == index:
						return index
		for index in range(0, 3):
			for item in formation:
					if formation[item] == index:
						return index

func checkBattleStatus():
	var allDead = true
	for ally in allyUnits.unitTypes:
		if unitRefs[ally].isAlive:
			allDead = false
	
	if allDead:
		battleEnd(false)
		return
		
	allDead = true
	for enemy in enemyUnits.unitTypes:
		if unitRefs[enemy].isAlive:
			allDead = false
		
	if allDead:
		battleEnd(true)
		return
	
func battleEnd(allyWin):
	set_process(false)
	resetAllVars()
	
	if allyWin:
		print("allies won")
		allyUnits.snared = false
		enemyUnits.queue_free()
		tile.enemyStationed = null
	else:
		print("enemies won")
		enemyUnits.snared = false
		allyUnits.queue_free()
		tile.unitStationed = null
		
	get_parent().removeBattle(tile)

func resetAllVars():
	unitRefs = {}
	attackRates = {}
	currentTargettedPosition = {}
	allyPositions = {}
	enemyPositions = {}

