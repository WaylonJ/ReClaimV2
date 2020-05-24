extends "res://MainGame/Units/Unit.gd"

var numBaseEnemy = 0

var baseEnemyScript = load("res://MainGame/Units/UnitTypes/BaseEnemy.gd")

var baseEnemyRef

var unitSizeTrigger = null
var unitSizeTriggerConstant = 1


func _init():
	isAlly = false
	generateUnitRefs()

func _ready():
	self.connect("mouse_entered", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseEntered", [self])
	self.connect("mouse_exited", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseExited")
	set_process(false)

func generateUnitRefs():
	leaderRef = leaderScript.new()
	add_child(leaderRef)
	
	baseEnemyRef = baseEnemyScript.new()
	add_child(baseEnemyRef)

func createUnit(unitName, amount):
	match unitName:
		"baseEnemy":
			unitTypes.append("baseEnemy")
			unitRefs["baseEnemy"] = baseEnemyRef
			baseEnemyRef.addFreshUnit(amount)
			numBaseEnemy += amount
			updateTotalStats()
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_BasicEnemy.png")
			get_node("BG").set("texture", portrait)
			setFormation("baseEnemy")
	numUnits = amount
	if numUnits < 2:
		get_node("NumUnits").hide()
	checkHighestVision()

func checkHighestVision():
	for item in unitTypes:
		match item:
			"baseEnemy":
				setVision(0)

func mergeUnits(newAddition):
	if newAddition.numBaseEnemy !=0:
		if numBaseEnemy == 0:
			unitTypes.append("baseEnemy")
			unitRefs["baseEnemy"] = baseEnemyRef
			setFormation("baseEnemy")
			
		numBaseEnemy += newAddition.numBaseEnemy
		baseEnemyRef.mergeUnit(newAddition.baseEnemyRef)
	numUnits += newAddition.numUnits
	updateTotalStats()
	checkAttackTrigger()
	
		
func setFormation(unit):
	# Ensures this unit type doesnt already have a position
	if !(unit in formation):
		match unit:
			"baseEnemy":
				setFormationClosestTo(1, unit)
			_:
				print("Unit.gd: we got a mis-match")
			
func getRef(unitName):
	match unitName:
		"baseEnemy":
			return baseEnemyRef

func checkAttackTrigger():
	if unitSizeTrigger == null:
		unitSizeTrigger = unitSizeTriggerConstant * hostTile.distanceFromBase
	
	if numUnits >= unitSizeTrigger:
		sendToBase()

func sendToBase():
	print("Sending enemy attack!!")
	rootRef.unitMovement.autoMoveUnit(self, rootRef.baseTile)
	
