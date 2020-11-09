extends HBoxContainer

const LEADER_ICON = preload("res://MainGame/Units/Resources/SmallIcons/PH_Unit_Leader_Small.png")
const GOBLIN_ICON = preload("res://MainGame/Units/Resources/SmallIcons/PH_Unit_Goblin_Small.png")

var unitGroup = null

# Determins if in the UI area or not
var inFormations = false
#var currentUnit = null
var currentPos = null
var originalPos = null

onready var tempImageNode = get_node("../../../../HiddenItems/CursorImage")
onready var rootRef = get_tree().get_root().get_node("Control")
onready var timeController = rootRef.timeController
onready var TIME_CONSTANT = timeController.TIME_CONSTANT

var mousePos = null

var timer = 0.05
var letGo = false
var skipFirstMouseMotion = false

# Ok this shit is a mess. When you hold down left click, _on_Mouse_Entered() doesn't fire
# So that resulted in a lot of janky shit to figure out how to get drag and drops to work
# idk if skipFirstMouseMotion does anything
#
# Current bug is that if you drag an empty tile onto a unit icon, it won't allow currentPos to be updated
# until another click is registered. No idea why.


func time_Update():
	if currentPos != null:
		switchOriginalAndCurrentPosUnits()
		
		# Ensures current position has the update node, because it can't update until it's 'moved' 
		get_viewport().warp_mouse(Vector2(mousePos[0] + 1, mousePos[1]))
		get_viewport().warp_mouse(Vector2(mousePos[0] - 1, mousePos[1]))
		originalPos = null
	timeController.object_removeItemFromGroup(self, "UI")
	currentPos = null
	originalPos = null
	letGo = false

func _ready():
	connectMouseEntered(self, self)
	tempImageNode.hide()
	
func _input(event):
#	print(event)
	if event is InputEventMouseButton and inFormations:
		if event.is_pressed():
			print("Letgo: " + str(letGo) + ", skipFirst: " + str(skipFirstMouseMotion))
			if currentPos != null:

#				print("clicked")
				setDragTexture(currentPos.get_node("UnitFormation"))
				setOriginalPos()
				fadeOriginalPosUnit()
		if !event.is_pressed() and originalPos != null:
			letGo = true
			skipFirstMouseMotion = true
			restoreFadeOriginalPosUnit()
			hideDragTexture()
	if event is InputEventMouseMotion:
		if letGo and !skipFirstMouseMotion:
			letGo = false
		skipFirstMouseMotion = false
		inputSetMousePositions(event)
		updateDragTexturePos()

func _mouseEntered(node):
	inFormations = true
	if node.name == "CenterContainer":
		print("setting cur Pos, " + str(node))
		currentPos = node
	if letGo:
		changePicture()

func changePicture():
	timeController.object_addItemToGroup(self, "UI")
	
	pass

func _mouseExited(node):
	inFormations = false
	if node.name == "CenterContainer":
		if currentPos != null:
			currentPos = null

func fadeOriginalPosUnit():
	var color = originalPos.get_node("UnitFormation").get_self_modulate()
	originalPos.get_node("UnitFormation").set_self_modulate(Color(color[0], color[1], color[2], 0.25))

func restoreFadeOriginalPosUnit():
	var color = originalPos.get_node("UnitFormation").get_self_modulate()
	originalPos.get_node("UnitFormation").set_self_modulate(Color(color[0], color[1], color[2], 1))

func switchOriginalAndCurrentPosUnits():
	var temp = originalPos.get_node("UnitFormation").get("texture")
	if currentPos == null or originalPos == null or temp == null:
#		print("returning")
		return
#	if currentPos == originalPos:
#		print("theyre the same")
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
