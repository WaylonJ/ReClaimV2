extends Camera2D

var myZoom

var currentZoomLevel = 1
var cameraDragging = false

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

onready var rectd = get_node("../SelectBoxHolder/ColorRect")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prevents weird slow drag until zoom occurs
	counterSlowDrag()
	myZoom = get_zoom()
	myZoom.x += 0.5
	myZoom.y += 0.5
	set_zoom(myZoom)
	draw_area(false)
	connect("area_selected", get_node("../UnitHolder/UnitController"), "_on_AreaSelected")
#	connect("area_selected", get_parent(), "_on_AreaSelected", [self])
#	connect("area_selected", script, "_on_AreaSelected", [self])
#	script._on_AreaSelected("a")
	pass # Replace with function body.

func _input(event):
	globalSelected = get_tree().get_root().get_node("Control").checkIfSomethingSelected()
	if globalSelected == "Battle":
		return
	
	#Controls mouse dragging if mouse is right-clicked and moved
	inputDragMouse(event)

	#Calls Zoom function if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP or DOWN
	inputZoomInOrOut(event)

	#Sets mouse positions on any InputEventMouse
	inputSetMousePositions(event)
	
	
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1 and event.position[1] < 540:
		start = mousePos
		startGlobal = mousePosGlobal
		boxDragging = true
	if boxDragging:
		end = mousePos
		endGlobal = mousePosGlobal
		draw_area()
	
	if event is InputEventMouseButton and !event.is_pressed() and event.button_index == 1 and boxDragging:
		if start.distance_to(mousePos) > 20:
			get_node("../UI/BottomUI/MiddleSection/TileInfo").emptyTileGroup()
			end = mousePos
			endGlobal = mousePosGlobal
			boxDragging = false
			draw_area(false)
			emit_signal("area_selected", [startGlobal, endGlobal])
		else:
			endGlobal = startGlobal
			boxDragging = false
			draw_area(false)

func inputSetMousePositions(event):
	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()
#		print(mousePos)
#		print(mousePosGlobal)
#		print(mousePosGlobal)

func inputDragMouse(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == 2:
			if event.position[1] < 540:
				previousPosition = event.position
				cameraDragging = true
		elif !event.is_pressed():
			cameraDragging = false
	if event is InputEventMouseMotion && cameraDragging:
		position += (previousPosition - event.position)*myZoom
		previousPosition = event.position

func inputZoomInOrOut(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoomIn()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoomOut()

func zoomIn():
	myZoom = get_zoom()
	if myZoom.x > 1.5:
		myZoom.x -= 0.15
		myZoom.y -= 0.15
#		currentZoomLevel -= 0.15
		set_zoom(myZoom)

func zoomOut():
	myZoom = get_zoom()
	if myZoom.x < 8:
		myZoom.x += 0.15
		myZoom.y += 0.15
#		currentZoomLevel += 0.15
		set_zoom(myZoom)
		
func counterSlowDrag():
	zoomOut()
	zoomIn()

func draw_area(s = true):
	rectd.rect_size = Vector2(abs(startGlobal.x - endGlobal.x), abs(startGlobal.y - endGlobal.y))
#	print(rectd.rect_size)
	
	var pos = Vector2()
	pos.x = min(startGlobal.x, endGlobal.x)
	pos.y = min(startGlobal.y, endGlobal.y)
	
#	print("pos: " + str(pos.x) + ", " + str(pos.y))
	
	rectd.rect_position = pos
	
	rectd.rect_size *= int(s)
	
#	print("Rect X / Y: " + str(rectd.get_position()))

