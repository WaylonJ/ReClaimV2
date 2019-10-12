extends HBoxContainer

const LEADER_ICON = preload("res://MainGame/UI/Resources/UnitsSmall/PH_Unit_Leader_Small.png")
const GOBLIN_ICON = preload("res://MainGame/UI/Resources/UnitsSmall/PH_Unit_Goblin_Small.png")

var unitGroup = null

# Determins if in the UI area or not
var inFormations = false
#var currentUnit = null
var currentPos = null
var originalPos = null

onready var tempImageNode = get_node("../../../../HiddenItems/CursorImage")

var mousePos = null

var timer = 0.05

func _process(delta):
	timer -= delta
	if timer <= 0:
		timer = 0.05
		
		if currentPos != null:
			# Ensures current position has the update node, because it can't update until it's 'moved' 
			get_viewport().warp_mouse(Vector2(mousePos[0] + 1, mousePos[1]))
			get_viewport().warp_mouse(Vector2(mousePos[0] - 1, mousePos[1]))
			switchOriginalAndCurrentPosUnits()
			originalPos = null
		set_process(false)
		currentPos = null
		originalPos = null

func _ready():
	connectMouseEntered(self, self)
	tempImageNode.hide()
	set_process(false)
	pass
	
func _input(event):
	if event is InputEventMouseButton and inFormations:
		if event.is_pressed():
			if currentPos != null:
				setDragTexture(currentPos.get_node("UnitFormation"))
				setOriginalPos()
				fadeOriginalPosUnit()
		if !event.is_pressed() and originalPos != null:
			restoreFadeOriginalPosUnit()
			set_process(true)
			hideDragTexture()
	if event is InputEventMouseMotion:
		inputSetMousePositions(event)
		updateDragTexturePos()

func _mouseEntered(node):
	inFormations = true
	if node.name == "CenterContainer":
		currentPos = node
#	if node.name == "UnitFormation":
#		if currentUnit == null:
#			currentUnit = node

func _mouseExited(node):
	inFormations = false
	if node.name == "CenterContainer":
		if currentPos != null:
			currentPos = null
#	if node.name == "UnitFormation":
#		if currentUnit != null:
#			currentUnit = null

func fadeOriginalPosUnit():
	var color = originalPos.get_node("UnitFormation").get_self_modulate()
	originalPos.get_node("UnitFormation").set_self_modulate(Color(color[0], color[1], color[2], 0.25))

func restoreFadeOriginalPosUnit():
	var color = originalPos.get_node("UnitFormation").get_self_modulate()
	originalPos.get_node("UnitFormation").set_self_modulate(Color(color[0], color[1], color[2], 1))

func switchOriginalAndCurrentPosUnits():
	var temp = originalPos.get_node("UnitFormation").get("texture")
	if currentPos == null or originalPos == null or temp == null:
		return
	originalPos.get_node("UnitFormation").set("texture", currentPos.get_node("UnitFormation").get("texture"))
	currentPos.get_node("UnitFormation").set("texture", temp)
	
	updateUnitFormation()
	
func updateUnitFormation():
	
	var position = [0, 1, 2, 3, 4, 5]
	var checkUnit = null
	
	for index in position:
		checkUnit = null
		match index:
			0:
				checkUnit = get_node("Left/PosTop/CenterContainer/UnitFormation").unit
			1:
				checkUnit = get_node("Mid/PosTop/CenterContainer/UnitFormation").unit
			2:
				checkUnit = get_node("Right/PosTop/CenterContainer/UnitFormation").unit
			3:
				checkUnit = get_node("Left/PosBot/CenterContainer/UnitFormation").unit
			4:
				checkUnit = get_node("Mid/PosBot/CenterContainer/UnitFormation").unit
			5:
				checkUnit = get_node("Right/PosBot/CenterContainer/UnitFormation").unit
		
		if checkUnit in unitGroup.formation:
			unitGroup.formation[checkUnit] = index
	

func inputSetMousePositions(event):
	if event is InputEventMouse:
		mousePos = event.position

func setDragTexture(node):
	tempImageNode.set("texture", node.get("texture"))
	tempImageNode.show()
	
func setOriginalPos():
	if originalPos == null:
		originalPos = currentPos

func hideDragTexture():
	tempImageNode.hide()
	
func updateDragTexturePos():
	tempImageNode.set_position(Vector2(mousePos[0] - 30, mousePos[1] - 30))

func connectMouseEntered(node, formations):
	for item in node.get_children():
		connectMouseEntered(item, formations)
	node.connect("mouse_entered", formations, "_mouseEntered", [node])
	node.connect("mouse_exited", formations, "_mouseExited", [node])

func initialize(group):
	emptyAllTiles()
	unitGroup = group
	updateUI()

func emptyAllTiles():
	get_node("Left/PosTop/CenterContainer/UnitFormation").set("texture", null)
	get_node("Mid/PosTop/CenterContainer/UnitFormation").set("texture", null)
	get_node("Right/PosTop/CenterContainer/UnitFormation").set("texture", null)
	get_node("Left/PosBot/CenterContainer/UnitFormation").set("texture", null)
	get_node("Mid/PosBot/CenterContainer/UnitFormation").set("texture", null)
	get_node("Right/PosBot/CenterContainer/UnitFormation").set("texture", null)

func updateUI():
	for item in unitGroup.formation:
		updateUITile(item, unitGroup.formation[item])
		
func updateUITile(unit, position):
	var icon = getIcon(unit)
	match position:
		0:
			get_node("Left/PosTop/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])
		1:
			get_node("Mid/PosTop/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])
		2:
			get_node("Right/PosTop/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])
		3:
			get_node("Left/PosBot/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])
		4:
			get_node("Mid/PosBot/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])
		5:
			get_node("Right/PosBot/CenterContainer/UnitFormation").setTexture(icon[0], icon[1])

func getIcon(unit):
	match unit:
		"Leader":
			return [LEADER_ICON, "Leader"]
		"Goblin":
			return [GOBLIN_ICON, "Goblin"]


