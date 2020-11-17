extends Camera2D

var myZoom

var currentZoomLevel = 1
var cameraDragging = false
var cameraDragged = false
var cameraDragPos 

var previousPosition: Vector2 = Vector2(0,0);

# Box Selection variables
var mousePos = Vector2()
var mousePosGlobal = Vector2()
var start = Vector2()
var startGlobal = Vector2()
var end = Vector2()
var endGlobal = Vector2()
var boxDragging = false

signal area_selected

var globalSelected = "e"

onready var hoverBldgRef = get_node("../UI/HiddenItems/HoveringBldgImage")
onready var rectd = get_node("../SelectBoxHolder/ColorRect")

func _ready():
	# Prevents weird slow drag until zoom occurs
	counterSlowDrag()
	
	# Default settings
	setDefaultSettings()
	
	# Connects function for unit box selection
	connect("area_selected", get_node("../UnitHolder/UnitController"), "_on_AreaSelected")

func input_receive(event):
	# Prevents any interaction when a battle screen is up
	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
	
	if globalSelected == "Battle":
		return
	
	#Controls mouse dragging if mouse is right-clicked and moved
	inputDragMouse(event)

	#Calls Zoom function if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP or DOWN
	inputZoomInOrOut(event)

	#Sets mouse positions on any InputEventMouse
	inputSetMousePositions(event)
	
	# Checking mouse position ensures the click wasn't done while over the UI
	checkNotOverUI(event)

	if boxDragging:
		end = mousePos
		endGlobal = mousePosGlobal
		draw_area()
	
	if event is InputEventMouseButton and !event.is_pressed() and event.button_index == 1 and boxDragging:
		if start.distance_to(mousePos) > 20:
			print("Greater than 20")
			get_node("../UI/BottomUI/MiddleSection/TileInfo").emptyTileGroup()
			end = mousePos
			endGlobal = mousePosGlobal
			boxDragging = false
			draw_area(false)
			print("Start: " + str(startGlobal) + ", End: " + str(endGlobal))
			emit_signal("area_selected", [startGlobal, endGlobal])
		else:
			endGlobal = startGlobal
			boxDragging = false
			draw_area(false)

func inputSetMousePositions(event):
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

func inputDragMouse(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 2:
			if event.position[1] < 540:
				previousPosition = event.position
				cameraDragPos = previousPosition
				cameraDragging = true
		elif !event.is_pressed():
			cameraDragging = false
			cameraDragged = false
	if event is InputEventMouseMotion && cameraDragging:
		determineIfCameraDragged(event.position)
		self.position += (previousPosition - event.position)*myZoom
		previousPosition = event.position

func determineIfCameraDragged(curPos):
	var xMove = cameraDragPos[0] - curPos[0]
	var yMove = cameraDragPos[1] - curPos[1]
	if (abs(xMove) + abs(yMove)) > 15:
		cameraDragged = true
	

func inputZoomInOrOut(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoomIn()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoomOut()

func setDefaultSettings():
	myZoom = get_zoom()
	myZoom.x += 0.5
	myZoom.y += 0.5
	set_zoom(myZoom)
	draw_area(false)

func zoomIn():
	myZoom = get_zoom()
	if myZoom.x > 1.5:
		myZoom.x -= 0.15
		myZoom.y -= 0.15
		set_zoom(myZoom)

func zoomOut():
	myZoom = get_zoom()
	if myZoom.x < 8:
		myZoom.x += 0.15
		myZoom.y += 0.15
		set_zoom(myZoom)
		
func counterSlowDrag():
	zoomOut()
	zoomIn()

func draw_area(s = true):
	rectd.rect_size = Vector2(abs(startGlobal.x - endGlobal.x), abs(startGlobal.y - endGlobal.y))
	
	var pos = Vector2()
	pos.x = min(startGlobal.x, endGlobal.x)
	pos.y = min(startGlobal.y, endGlobal.y)
	rectd.rect_position = pos
	
	# If true, will be 1 and shown. If false, will be 0 and not shown
	rectd.rect_size *= int(s)
	
func checkNotOverUI(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1 and event.position[1] < 540:
		start = mousePos
		startGlobal = mousePosGlobal
		
		# Checks to see if a building is currently selected to be built.
		if !checkBldgSelected():
			boxDragging = true

func checkBldgSelected():
	if hoverBldgRef.selectedBldg != null:
		return true
	return false
