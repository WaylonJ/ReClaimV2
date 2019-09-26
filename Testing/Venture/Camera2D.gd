extends Camera2D

var myZoom = 0.5

var currentZoomLevel = 1
var _drag = false

var previousPosition: Vector2 = Vector2(0,0);

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prevents weird slow drag until zoom occurs
	counterSlowDrag()
	
	pass # Replace with function body.

func _input(event):
	#Controls mouse draggins
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.position[1] < 540:
				previousPosition = event.position
				_drag = true
		elif !event.is_pressed():
			_drag = false
	if event is InputEventMouseMotion && _drag:
		position += (previousPosition - event.position)*myZoom
		previousPosition = event.position

	#Calls Zoom function
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zoomIn()
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoomOut()

func zoomIn():
	myZoom = get_zoom()
	if myZoom.x > 1:
		myZoom.x -= 0.05
		myZoom.y -= 0.05
		currentZoomLevel -= 0.05
		set_zoom(myZoom)

func zoomOut():
	myZoom = get_zoom()
	if myZoom.x < 8:
		myZoom.x += 0.05
		myZoom.y += 0.05
		currentZoomLevel += 0.05
		set_zoom(myZoom)
		
func counterSlowDrag():
	zoomOut()
	zoomIn()