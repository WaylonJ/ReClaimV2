extends Sprite

# Holds the various battles currently taking place, format of each item is [ally, enemy, tile]
var battles = []

var skillUnitPositions = []


func _ready():
	initializeSkillUnitPositions()
	pass 

func addBattle(ally, enemy, tile):
	battles.append([ally, enemy, tile])
	
	
func openBattleScreen(tile):
	for item in battles:
		if item[2] == tile:
			showBattle(item)

func showBattle(battle):
	var allyGroup = battle[0]
	var enemyGroup = battle[1]
	var tile = battle[2]
	
	initializeSkillsArea()
	
	# If number of battles > 1, show tab on left side to swap between them
	# checkIfShowTab()
	
#	addAlliesToSkillsArea(allyGroup)
#	addAllUnitsToBattleArea(ally, enemy)
	
func initializeSkillsArea():
	pass
	
func initializeSkillUnitPositions():
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/LeftUnits/BackUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/LeftUnits/FrontUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/MidUnits/BackUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/MidUnits/FrontUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/RightUnits/BackUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/RightUnits/FrontUnit"))
	
func addAlliesToSkillsArea(allyGroup):
	for unit in allyGroup.unitTypes:
		setUnitToPositionInSkillsArea(unit, allyGroup.formations[unit])

func setUnitToPositionInSkillsArea(unit, position):
	
	
	match position:
		_:
			print("Nothing matched")
	pass
		
