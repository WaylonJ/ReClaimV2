extends Node

var root = null

var reference_camera = null
var reference_unitController = null
var reference_battleScreen = null
var reference_tileInfo = null
var reference_hoveringBldgImg = null
var reference_formation = null
var reference_unitMovement = null
var reference_event = null

var reference_all = [reference_camera, reference_unitController, 
					reference_battleScreen, reference_tileInfo, reference_hoveringBldgImg, 
					reference_formation, reference_unitMovement, reference_event]

var input_unitController = true
var input_camera = true
var input_battleScreen = true
var input_tileInfo = true
var input_hoveringBldgImg = true
var input_formation = true
var input_unitMovement = true
var input_event = false

var input_all = [input_unitController, input_camera, 
				input_battleScreen, input_tileInfo, input_hoveringBldgImg, 
				input_formation, input_unitMovement, input_event]

func _ready():
	root = get_tree().get_root()
	
	reference_unitController = root.get_node("Control/UnitHolder/UnitController")
	reference_camera = root.get_node("Control/Camera2D")
	reference_battleScreen = root.get_node("Control/BattleScreen")
	reference_tileInfo = root.get_node("Control/UI/BottomUI/MiddleSection/TileInfo")
	reference_hoveringBldgImg = root.get_node("Control/UI/HiddenItems/HoveringBldgImage")
	reference_formation = root.get_node("Control/UI/BottomUI/MiddleSection/UnitInformation/Formation")
	reference_unitMovement = root.get_node("Control").unitMovement

func _input(event):

	
	# UNIT_CONTROLLER: selection and orders given
	if input_all[0]:
		reference_unitController.input_receive(event)
	
	# CAMERA: scrolls, box selects, mouse drags etc
	if input_all[1]:
		reference_camera.input_receive(event)
	
	# BATTLE_SCREEN: 'Esc' to be used to exit BattleScreens. Should also do clicks TBD
	if input_all[2]:
		reference_battleScreen.input_receive(event)
	
	# TILE_INFO: Tile selection, multiple at once, 'Esc' to discard all
	if input_all[3]:
		reference_tileInfo.input_receive(event)
	
	# HOVERING_BLDG_IMG: Shows building to be created when selected in Cosntruction menu
	if input_all[4]:
		reference_hoveringBldgImg.input_receive(event)
	
	# FORMATION: Controls setting the formation of Unit groups in the UI
	if input_all[5]:
		reference_formation.input_receive(event)
	
	# UNIT_MOVEMENT: Controls unit movement, sending orders, overwriting orders, etc.
	if input_all[6]:
		reference_unitMovement.input_receive(event)
		
	# EVENT: Controls input when event screen is open
	if input_all[7] and event is InputEventMouseButton:
		reference_event.input_receive(event)
	
func event_addListener(event):
	reference_event = event
	input_turnAllOff()
	
	# EVENT:
	input_all[7] = true

func event_removeListener():
	reference_event = null
	input_turnAllOn()
	
	# EVENT:
	input_all[7] = false
	
func input_turnAllOff():
	var counter = 0
	for input in input_all:
		input_all[counter] = false
		counter += 1

func input_turnAllOn():
	var counter = 0
	for input in input_all:
		input_all[counter] = true
		counter += 1
