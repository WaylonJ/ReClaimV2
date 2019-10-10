extends VBoxContainer

var curHP = 0
var maxHP = 0
var offense = 0
var defense = 0
var speed = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func updateStats(unit):
	curHP += unit.currentHealth
	maxHP += unit.maxHealth
	offense += unit.offense
	defense += unit.defense
	speed += unit.speed
	
	get_node("StatHolderHealth/Label").set_text(str(curHP) + " / " + str(maxHP))
	get_node("StatHolderOffense/Label").set_text(str(offense))
	get_node("StatHolderDefense/Label").set_text(str(defense))
	get_node("StatHolderSpeed/Label").set_text(str(speed))
	
func resetStats():
	curHP = 0
	maxHP = 0
	offense = 0
	defense = 0
	speed = 0
