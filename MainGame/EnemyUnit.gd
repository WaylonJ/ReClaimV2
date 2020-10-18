extends "res://MainGame/Units/Unit.gd"

var numBaseEnemy = 0

var baseEnemyScript = load("res://MainGame/Units/UnitTypes/BaseEnemy.gd")

var baseEnemyRef

var unitSizeTrigger = null
var unitSizeTriggerConstant = 3


func _init():
	isAlly = false
	basic_generateUnitRefs()

func _ready():
	self.connect("mouse_entered", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseEntered", [self])
	self.connect("mouse_exited", get_tree().get_root().get_node("Control/UnitHolder/EnemyController"), "_mouseExited")
	set_process(false)

func basic_generateUnitRefs():
	leaderRef = leaderScript.new()
	add_child(leaderRef)
	
	baseEnemyRef = baseEnemyScript.new()
	add_child(baseEnemyRef)

func stats_createUnit(unitName, amount):
	match unitName:
		"baseEnemy":
			unitTypes.append("baseEnemy")
			unitRefs["baseEnemy"] = baseEnemyRef
			baseEnemyRef.addFreshUnit(amount)
			numBaseEnemy += amount
			stats_updateTotalStats()
			
			portrait = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_BasicEnemy.png")
			get_node("BG").set("texture", portrait)
			ui_setFormation("baseEnemy")
	numUnits = amount
	
	ui_showNumberOfUnitsTag()	
	checkHighestVision()

func checkHighestVision():
	for item in unitTypes:
		match item:
			"baseEnemy":
				vision_setNew(0)

func stats_mergeUnits(newAddition):
	if newAddition.numBaseEnemy !=0:
		if numBaseEnemy == 0:
			unitTypes.append("baseEnemy")
			unitRefs["baseEnemy"] = baseEnemyRef
			ui_setFormation("baseEnemy")
			
		numBaseEnemy += newAddition.numBaseEnemy
		baseEnemyRef.mergeUnit(newAddition.baseEnemyRef)
	numUnits += newAddition.numUnits
	stats_updateTotalStats()
	
func stats_mergeWithOtherGroup(newAddition):
	# Merge the units and the stats together
	stats_mergeUnits(newAddition)
	
	if hostTile.inBattle:
		rootRef.get_node("BattleScreen").refreshUnits(hostTile)
	
	if hostTile.buildingAlliance == "enemy":
		checkAttackTrigger()
	
func ui_setFormation(unit):
	# Ensures this unit type doesnt already have a position
	if !(unit in formation):
		match unit:
			"baseEnemy":
				ui_setFormationClosestTo(1, unit)
			_:
				print("Unit.gd: we got a mis-match")
			
func basic_getRef(unitName):
	match unitName:
		"baseEnemy":
			return baseEnemyRef

func checkAttackTrigger():
	if unitSizeTrigger == null:
		unitSizeTrigger = floor(unitSizeTriggerConstant * (pow(hostTile.distanceFromBase, 1.2)))
	
	if numUnits >= unitSizeTrigger:
		print("Unit size: " + str(unitSizeTrigger))
		sendToBase()

func sendToBase():
	print("Sending enemy attack!!")
	rootRef.unitMovement.autoMoveUnit(self, rootRef.baseTile)
	
