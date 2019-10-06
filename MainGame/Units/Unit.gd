extends Button

var numLeader = 0
var numGoblin = 0

var currentHealth = 0
var maxHealth = 0
var offense = 0
var defense = 0
var speed = 0
var numUnits = 0

var hostTile = null

func _ready():
	self.connect("pressed", get_tree().get_root().get_node("Control/UnitHolder/UnitController"), "_unitClicked", [self])
	self.connect("mouse_entered", get_tree().get_root().get_node("Control/UnitHolder/UnitController"), "_mouseEntered")
	self.connect("mouse_exited", get_tree().get_root().get_node("Control/UnitHolder/UnitController"), "_mouseExited")
	pass # Replace with function body.

func setTile(tile):
	hostTile = tile
	
func createUnit(unitName, amount):
	match unitName:
		"Leader":
			numLeader += amount
			offense = amount * 20
			defense = amount * 20
			speed = amount * 10
			currentHealth = amount * 100
			maxHealth = amount * 100
		"Goblin":
			numGoblin += amount
			offense = amount * 5
			defense = amount * 5
			speed = amount * 10
			currentHealth = amount * 20
			maxHealth = amount * 20
	
	numUnits = amount
	if numUnits < 2:
		get_node("NumUnits").hide()

func mergeWithOtherGroup(newAddition):
	numLeader += newAddition.numLeader
	numGoblin += newAddition.numGoblin
	numUnits += newAddition.numUnits
	
	offense += newAddition.offense
	defense += newAddition.defense
	speed += newAddition.speed
	currentHealth += newAddition.currentHealth
	maxHealth += newAddition.maxHealth
	
	if numUnits > 1:
		get_node("NumUnits").show()
		get_node("NumUnits").set_text("x" + str(numUnits))
	else:
		get_node("NumUnits").hide()
	
	newAddition.queue_free()