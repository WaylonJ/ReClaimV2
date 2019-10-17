extends Sprite

# Holds the various battles currently taking place, format of each item is [ally, enemy, tile]
var battles = []

var skillUnitPositions = []
var tileUnitPositions = []

var battleHolder
var oldZoom

var battleController

func _ready():
	initializeSkillAndTileUnitPositions()
	battleHolder = get_node("Panel/HBoxContainer/BattleHolder")
	battleController = load("res://MainGame/BattleScreen/BattleController.gd").new()
	add_child(battleController)
	pass 
	
func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		hideBattleScreen()
		

func addBattle(ally, enemy, tile):
	battles.append([ally, enemy, tile])
	battleController.addBattle(ally, enemy, battleHolder.tiles)
	
func openBattleScreen(tile):
	show()
	get_tree().get_root().get_node("Control").selectSomething("Battle")
	for item in battles:
		if item[2] == tile:
			showBattle(item)

func hideBattleScreen():
	hide()
	get_node("/root/Control").unselectEverything()
	showOrHideUI("show")
	get_node("/root/Control/Camera2D").set_zoom(oldZoom)
	

func showBattle(battle):
	var allyGroup = battle[0]
	var enemyGroup = battle[1]
	var tile = battle[2]
	
	initializeSkillsArea(allyGroup)
	initializeBattleArea(allyGroup, true)
	initializeBattleArea(enemyGroup, false)
	
	showOrHideUI("hide")
	editCameraToMakeBattleScreenLookGood()
	
	# If number of battles > 1, show tab on left side to swap between them
	# checkIfShowTab()
	
	
func editCameraToMakeBattleScreenLookGood():
	var camera = get_node("/root/Control/Camera2D")

	# Zooms cam in so that it makesthe Battlescreen items look normal sized. Saves old zoom to return
	oldZoom = camera.get_zoom()
	camera.set_zoom(Vector2(1.2, 1.2))
	
	# Repositions the battlescreen for wherever the camera currently is
	repositionBattleScreen(camera)

func repositionBattleScreen(camera):
	var camPos = camera.get_position()
	var battlePos = get_position()
	var difference = Vector2(camPos[0] - battlePos[0], camPos[1] - battlePos[1])
	var recenter = Vector2(-110, -90)
	
	battlePos += difference
	battlePos += recenter
	set_position(battlePos)
	
func showOrHideUI(switch):
	var uiPath = get_node("/root/Control/UI")
	
	if switch == "hide":
		uiPath.get_node("BottomUI_BG").hide()
		uiPath.get_node("BottomUI").hide()
	elif switch == "show":
		uiPath.get_node("BottomUI_BG").show()
		uiPath.get_node("BottomUI").show()
	
func initializeBattleArea(unitGroup, isAlly):
	var position
	var image
	
	for unit in unitGroup.formation:
		position = unitGroup.formation[unit]
		
		match unit:
			"Leader":
				image = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Leader.png")
			"Goblin":
				image = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_Goblin.png")
			"baseEnemy":
				image = load("res://MainGame/Units/Resources/TileIcons/PH_Unit_BasicEnemy.png")
			_:
				print("BattleScreen.gd: Invalid match found")
				
		if isAlly:
			battleHolder.setUnitToPosition(unitGroup.unitRefs[unit], image, position)
		else:
			battleHolder.setEnemyToPosition(unitGroup.unitRefs[unit], image, position)
	
func initializeSkillsArea(ally):
	var position
	var unitName
	
	for unit in ally.formation:
		match unit:
			"Leader":
				position = ally.formation[unit]
				unitName = unit
			"Goblin":
				position = ally.formation[unit]
				unitName = unit
				pass
			_:
				print("BattleScreen.gd: Invalid match found")
		
		setSkillsBasedOnUnit(unitName, skillUnitPositions[position])
		
		
		match position:
			0:
				pass
			1:
				pass
			2:
				pass
			3:
				pass
			4:
				pass
			5:
				pass
	pass
	
func setSkillsBasedOnUnit(name, unitNode):
	match name:
		"Leader":
			var portrait = load("res://MainGame/Units/Resources/SmallIcons/PH_Unit_Leader_Small.png")
			unitNode.setUnitPortrait(portrait)
			
			var skillOneImage = load("res://MainGame/Units/Resources/Skills/PH_Skills_Leader_HeavyStrike.png")
			unitNode.setSkill(1, skillOneImage)
		"Goblin":
			var portrait = load("res://MainGame/Units/Resources/SmallIcons/PH_Unit_Goblin_Small.png")
			unitNode.setUnitPortrait(portrait)
			
			var skillOneImage = load("res://MainGame/Units/Resources/Skills/PH_Skills_Goblin_Flurry.png")
			unitNode.setSkill(1, skillOneImage)
	
	
func initializeSkillAndTileUnitPositions():
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/LeftUnits/FrontUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/MidUnits/FrontUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/RightUnits/FrontUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/LeftUnits/BackUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/MidUnits/BackUnit"))
	skillUnitPositions.append(get_node("Panel/HBoxContainer/UnitInfoAndSkills/RightUnits/BackUnit"))
	
	
func addAlliesToSkillsArea(allyGroup):
	for unit in allyGroup.unitTypes:
		setUnitToPositionInSkillsArea(unit, allyGroup.formations[unit])

func setUnitToPositionInSkillsArea(unit, position):
	
	
	match position:
		_:
			print("Nothing matched")
	pass
		
